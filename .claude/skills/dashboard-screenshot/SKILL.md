---
name: dashboard-screenshot
description: Take a screenshot of the Pulsedeck dashboard and look at it. Use after changes to views, components, layouts, CSS or widgets, or when asked to check, verify or show how the dashboard looks.
---

# Dashboard screenshot

Start the server, take headless Chromium screenshots, stop the server.

## Steps

1. Run the script in the Nix dev shell:
   - Default size (the Raspberry Pi screen, 1024x600):
     `nix develop -c .claude/skills/dashboard-screenshot/screenshot.sh`
   - Other sizes (use for layout changes):
     `nix develop -c .claude/skills/dashboard-screenshot/screenshot.sh 800x480 1024x600 1920x1080`
2. The script prints one PNG path for each size. Files are in `tmp/screenshots/` (ignored by git).
3. Open each PNG with the Read tool. Look at the image.
4. Report what you see.

## Check

- Each widget is complete and inside the screen. No clipped or overlapping widgets.
- No horizontal scroll or overflow at any size.
- Text is easy to read. Contrast is good on the dark background.
- The title and all configured widgets show.
- Values show. `N/A` is correct on a host without the AMD hardware. It is not a bug.

## Rules

- Do not say the visuals are correct before you read the image.
- The screenshot shows the state after about 2.5 seconds. It does not show long-term live updates.
- If the script fails, read its error output. Do not install browsers outside the dev shell.
