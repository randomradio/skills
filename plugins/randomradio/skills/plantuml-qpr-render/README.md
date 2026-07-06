# plantuml-qpr-render

Render PlantUML diagrams with qpr and show previews inside Claude/Codex-style sessions.

## What It Does

- Detects qpr, Docker, Kitty, watch tools, and PlantUML fallback options.
- Prefers qpr from https://github.com/hwblx/qpr for PNG/SVG/TXT rendering.
- Shows rendered PNGs as Markdown image previews when the session supports local images.
- Keeps `.puml`, PNG/SVG/TXT, and optional HTML preview files under the current project or `$PLANTUML_QPR_RENDER_DIR`.
- Uses qpr terminal watch mode when Kitty plus `inotifywait` are available.
- Uses an `fswatch` loop on macOS when qpr rendering is available but qpr watch mode is not.

## Files

- `SKILL.md` - main workflow, detection tree, defaults, and response template
- `references/qpr-commands.md` - install and render command recipes
- `references/troubleshooting.md` - common failure modes and fixes

## Quick Use

Ask for any of these:

- "Render this PlantUML and show me the preview."
- "Use qpr to preview this .puml file."
- "Create a C4 PlantUML diagram and render it."
- "Keep a live preview of this sequence diagram while we edit it."

The skill defaults to a qpr PNG render plus a local Markdown image preview in `outputs/plantuml-preview/`, `work/plantuml-preview/`, or `.plantuml-preview/` inside the current project unless `$PLANTUML_QPR_RENDER_DIR` is explicitly set.
