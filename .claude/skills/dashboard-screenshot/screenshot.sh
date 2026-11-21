#!/usr/bin/env bash
# Take headless Chromium screenshots of the running dashboard.
# Usage: screenshot.sh [WIDTHxHEIGHT ...]   (default: 1024x600)
# Run inside the Nix dev shell: nix develop -c .claude/skills/dashboard-screenshot/screenshot.sh
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$root"

sizes=("$@")
[ ${#sizes[@]} -eq 0 ] && sizes=(1024x600)

out="$root/tmp/screenshots"
mkdir -p "$out"
log="$(mktemp)"
profile="$(mktemp -d)"

port="$(ruby -rsocket -e 'puts TCPServer.new(0).addr[1]')"
bundle exec rackup --port "$port" >"$log" 2>&1 &
server=$!
cleanup() {
  kill "$server" 2>/dev/null || true
  wait "$server" 2>/dev/null || true
  rm -rf "$log" "$profile"
}
trap cleanup EXIT

url="http://127.0.0.1:$port/"
for _ in $(seq 1 60); do
  curl -sf -o /dev/null "$url" && break
  kill -0 "$server" 2>/dev/null || { echo "Server stopped:" >&2; cat "$log" >&2; exit 1; }
  sleep 0.25
done
curl -sf -o /dev/null "$url" || { echo "Server did not start:" >&2; cat "$log" >&2; exit 1; }

for size in "${sizes[@]}"; do
  [[ "$size" =~ ^[0-9]+x[0-9]+$ ]] || { echo "Bad size '$size'. Use WIDTHxHEIGHT." >&2; exit 2; }
  file="$out/dashboard-$size.png"
  timeout 30 chromium --headless --disable-gpu --no-sandbox --hide-scrollbars \
    --user-data-dir="$profile" --window-size="${size/x/,}" \
    --timeout=2500 --screenshot="$file" "$url" >/dev/null 2>&1
  [ -s "$file" ] || { echo "No screenshot for $size" >&2; exit 1; }
  echo "$file"
done
