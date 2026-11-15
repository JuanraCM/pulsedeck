# typed: false
# frozen_string_literal: true

# An open SSE stream never ends by itself. Without this, Puma waits for it forever on shutdown.
force_shutdown_after 1
