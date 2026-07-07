---
name: rr:plantuml-qpr-render
description: >
  Render PlantUML diagrams with qpr and show live previews in agent sessions.
  Triggers: "render PlantUML", "preview PlantUML", "show this puml", "draw this UML",
  "turn this @startuml into an image", "qpr render", "PlantUML live preview",
  "diagram preview", "render a sequence diagram", "render C4 PlantUML", "PlantUML HTML preview",
  "plantuml-skill setup .svg", "plantuml-skill setup .png", "/plantuml-skill setup .png".
  Also use when the user gives PlantUML code, asks to edit a .puml file and see the result,
  or wants a Claude/Codex chat preview backed by qpr with all rendered files kept in the
  current project or an explicitly configured global preview directory. Defaults to SVG output
  unless the user changes the persistent default with plantuml-skill setup .{ext}.
version: 1.1.0
license: MIT
metadata:
  hermes:
    tags: [PlantUML, Diagrams, qpr, Rendering]
---

# PlantUML qpr Render

Use this skill to turn PlantUML source into a rendered image during Claude/Codex-style sessions. Prefer `qpr` from https://github.com/hwblx/qpr for rendering, default to SVG images, then display the generated image in the richest preview surface available. Keep rendering qpr-centered and local.

## Step 1: Detect Runtime and Preview Capabilities

Run these checks before choosing a render path:

```bash
(command -v qpr >/dev/null && qpr --help | sed -n '1p') 2>/dev/null || echo "QPR_MISSING"
```

```bash
(command -v docker >/dev/null && docker info >/dev/null 2>&1 && echo "DOCKER_READY") 2>/dev/null || echo "DOCKER_UNAVAILABLE"
```

```bash
(docker image inspect plantuml/plantuml:latest >/dev/null 2>&1 && echo "PLANTUML_IMAGE_READY") 2>/dev/null || echo "PLANTUML_IMAGE_MISSING"
```

```bash
(curl -sfI http://localhost:8080 >/dev/null 2>&1 && echo "PLANTUML_SERVER_READY") 2>/dev/null || echo "PLANTUML_SERVER_NOT_READY"
```

```bash
(command -v kitten >/dev/null && echo "KITTEN_READY") 2>/dev/null || echo "KITTEN_MISSING"
```

```bash
(command -v inotifywait >/dev/null && echo "INOTIFY_READY") 2>/dev/null || echo "INOTIFY_MISSING"
```

```bash
(command -v fswatch >/dev/null && echo "FSWATCH_READY") 2>/dev/null || echo "FSWATCH_MISSING"
```

```bash
(command -v plantuml >/dev/null && plantuml -version | sed -n '1p') 2>/dev/null || echo "PLANTUML_CLI_MISSING"
```

```bash
(command -v curl >/dev/null && echo "CURL_READY") 2>/dev/null || echo "CURL_MISSING"
```

```bash
(command -v git >/dev/null && git --version) 2>/dev/null || echo "GIT_MISSING"
```

```bash
PLANTUML_QPR_CONFIG="${PLANTUML_QPR_CONFIG:-$HOME/.config/randomradio/plantuml-qpr-render/config}"
if [ -f "$PLANTUML_QPR_CONFIG" ]; then sed -n 's/^output_format=/CONFIG_OUTPUT_FORMAT=/p' "$PLANTUML_QPR_CONFIG" | tail -1; else echo "CONFIG_OUTPUT_FORMAT_DEFAULT=svg"; fi
```

```bash
uname -s 2>/dev/null || echo "UNAME_UNAVAILABLE"
```

```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd); printf 'PROJECT_ROOT=%s\n' "$PROJECT_ROOT"
```

```bash
if [ -n "$PLANTUML_QPR_RENDER_DIR" ]; then mkdir -p "$PLANTUML_QPR_RENDER_DIR" 2>/dev/null && test -w "$PLANTUML_QPR_RENDER_DIR" && printf 'GLOBAL_RENDER_DIR=%s\n' "$PLANTUML_QPR_RENDER_DIR" || echo "GLOBAL_RENDER_DIR_UNWRITABLE"; else echo "GLOBAL_RENDER_DIR_NOT_SET"; fi
```

**Decision tree:**
1. First choose a controlled artifact root. If `GLOBAL_RENDER_DIR=/path` is writable, use that global directory. Otherwise use a project-local directory from Step 2.
2. If the user asks `plantuml-skill setup .svg` or `plantuml-skill setup .png` with or without a leading slash, update the persistent output-format config in Step 2 and stop unless the user also supplied a diagram to render.
3. If `qpr` and `DOCKER_READY` are available, use qpr as the renderer.
4. If the session can show local images in chat, use **Method A: qpr chat preview**. This is the default for Codex desktop and similar local agent apps.
5. If `KITTEN_READY` and `INOTIFY_READY` are also available, use **Method B: qpr terminal live preview** when the user asks for a continuously updating terminal preview.
6. If `INOTIFY_READY` is missing but `FSWATCH_READY` exists, use **Method C: qpr plus fswatch** as a macOS-friendly watch loop.
7. If `qpr` is missing but `curl` or `git` is available and Docker is ready, install qpr workspace-locally, then return to Method A.
8. If Docker is unavailable but `plantuml` CLI exists, use **Method D: PlantUML CLI fallback** and tell the user qpr was not available in this runtime.
9. If no renderer is available, create or update the `.puml` source in the controlled artifact root and provide exact setup steps from `references/qpr-commands.md`.

## Step 2: Normalize Inputs and Defaults

### Persistent Output Format Setup

When the user's request is only `plantuml-skill setup .{ext}` or `/plantuml-skill setup .{ext}`, treat it as a configuration command. Supported persistent image formats are `.svg` and `.png`; keep `.txt`/`.atxt` as one-off render requests rather than the default chat image format.

```bash
REQUESTED_EXT=".png" # parse from the user's setup request
PLANTUML_QPR_CONFIG="${PLANTUML_QPR_CONFIG:-$HOME/.config/randomradio/plantuml-qpr-render/config}"
case "$REQUESTED_EXT" in
  .svg|svg) OUTPUT_FORMAT="svg" ;;
  .png|png) OUTPUT_FORMAT="png" ;;
  *) echo "UNSUPPORTED_OUTPUT_FORMAT $REQUESTED_EXT"; exit 2 ;;
esac
mkdir -p "$(dirname "$PLANTUML_QPR_CONFIG")"
printf 'output_format=%s\n' "$OUTPUT_FORMAT" > "$PLANTUML_QPR_CONFIG"
printf 'PLANTUML_OUTPUT_FORMAT=%s\n' "$OUTPUT_FORMAT"
```

For ordinary render requests, resolve the default format before choosing commands:

```bash
PLANTUML_QPR_CONFIG="${PLANTUML_QPR_CONFIG:-$HOME/.config/randomradio/plantuml-qpr-render/config}"
CONFIG_OUTPUT_FORMAT=$(sed -n 's/^output_format=//p' "$PLANTUML_QPR_CONFIG" 2>/dev/null | tail -1)
case "$CONFIG_OUTPUT_FORMAT" in
  svg|png) OUTPUT_FORMAT="$CONFIG_OUTPUT_FORMAT" ;;
  *) OUTPUT_FORMAT="svg" ;;
esac
OUTPUT_EXT=".$OUTPUT_FORMAT"
OUTPUT_FLAG="--$OUTPUT_FORMAT"
```

Use these defaults so the skill does not stall:

| Parameter | Default if missing | Rationale |
|---|---|---|
| Source input | Existing `.puml` file if named; otherwise PlantUML code in the prompt; otherwise generate source from the user's diagram request | Covers file, code, and natural-language entry points |
| Controlled artifact root | `$PLANTUML_QPR_RENDER_DIR` if set and writable; otherwise `$PROJECT_ROOT/outputs/plantuml-preview/` when an outputs directory exists; otherwise `$PROJECT_ROOT/work/plantuml-preview/`; otherwise `$PROJECT_ROOT/.plantuml-preview/` | Keeps all qpr inputs and outputs in the current project or an explicit global directory |
| Source path | `<controlled-root>/<slug>/<slug>.puml` for generated or copied previews | qpr writes rendered files beside the source, so the source location controls the output location |
| Output format | SVG unless `plantuml-skill setup .png` configured PNG | Scalable by default; PNG remains available for UIs that need raster images |
| Output path | Same basename as the controlled source, beside the `.puml` file | Matches qpr's output behavior while keeping artifacts in bounds |
| HTML preview path | `<controlled-root>/<slug>/index.html` only when the user asks for HTML or the UI needs an HTML wrapper | qpr renders images/text, while HTML is an optional wrapper artifact |
| File overwrite | Do not overwrite an existing file unless the user named it or asked to edit it | Protects user work |
| Render mode | qpr chat preview | Works in the most agent sessions |
| Watch mode | Agent-managed re-render after each edit | Reliable across macOS/Linux and local chat UIs |
| Server mode | Use `--server` only for repeated renders or explicit live work | Avoids starting containers for one-off renders |
| Terminal print | Off unless the user asks or Kitty is detected | Chat preview is usually clearer in Codex/Claude sessions |

Never run qpr against a temporary source outside the controlled artifact root. If the user names a `.puml` file outside the current project or outside `$PLANTUML_QPR_RENDER_DIR`, copy it into the controlled artifact root first and render the copy. If the user names a `.puml` file already inside the current project, either render it in place or copy it into the project-local preview root; prefer the preview root when the user did not ask to modify the original file.

If source text lacks `@startuml` and `@enduml`, wrap it. Preserve existing `!include`, C4, theme, skinparam, and layout directives.

## Step 3: Prepare qpr Without Blocking

Set `QPR=$(command -v qpr 2>/dev/null)` when `qpr` is on `PATH`. If not, install a pinned workspace-local copy before rendering and set `QPR="$PROJECT_ROOT/.tools/bin/qpr"`:

1. Prefer `curl` from the pinned qpr commit in `references/qpr-commands.md` into `.tools/bin/qpr`, then verify its SHA256.
2. If `curl` is unavailable, use `git clone --depth 1 https://github.com/hwblx/qpr.git .tools/qpr` and run `.tools/qpr/qpr`.
3. Do not install globally or write into the user's home directory unless they explicitly ask.
4. If Docker is ready but the PlantUML image is missing, run `docker pull plantuml/plantuml:latest` before invoking qpr so qpr does not pause for an interactive prompt.
5. If using `--server`, also pre-pull `plantuml/plantuml-server:jetty` so qpr does not pause for an interactive prompt.

Install workspace-local qpr under the current project, not under the controlled artifact root, unless those are the same directory. Use `"$QPR"` for all qpr invocations after detection or installation so separate shell sessions do not lose the workspace-local path. Read `references/qpr-commands.md` for copy-paste setup and render commands.

## Step 4: Render and Preview

Choose the first viable method from Step 1.

### Method A: qpr Chat Preview

Use for Codex desktop, Claude Code with local files, or any agent UI that can display local images:

```bash
"$QPR" "$OUTPUT_FLAG" --quiet "$PUML_FILE"
```

Then verify the selected output exists and show it with an absolute Markdown image path:

```bash
OUTPUT_FILE="${PUML_FILE%.puml}${OUTPUT_EXT}"
test -s "$OUTPUT_FILE" && printf 'RENDER_OK %s\n' "$OUTPUT_FILE" || echo "RENDER_MISSING"
```

```markdown
![PlantUML preview](/absolute/path/to/diagram.svg)
```

For live editing, re-run qpr after every PlantUML change and send an updated preview. This is the most reliable "live preview" mode in local chat sessions.

### Method B: qpr Terminal Live Preview

Use only when `kitten`, `inotifywait`, qpr, and Docker are ready:

```bash
"$QPR" --server --grid=1x1 --watch "$PUML_FILE"
```

Use `--append` only when the user wants render history instead of in-place updates. If the agent starts a watch process, keep track of it and stop it before the final response unless the user explicitly asks to leave it running.

### Method C: qpr plus fswatch

Use on macOS when `qpr --watch` is unavailable because `inotifywait` is missing:

```bash
while fswatch -1 "$PUML_FILE"; do
  "$QPR" "$OUTPUT_FLAG" --quiet "$PUML_FILE"
done
```

If Kitty is available and the user wants terminal graphics, run `"$QPR" --print --quiet "$PUML_FILE"` inside the loop after each render. Stop the loop before final response unless persistent watch was requested.

### Method D: PlantUML CLI Fallback

Use only when qpr cannot run but `plantuml` exists:

```bash
plantuml "-t$OUTPUT_FORMAT" "$PUML_FILE"
```

Tell the user this was a fallback and include what prevented qpr use.

## Step 5: Validate and Iterate

After rendering:

1. Confirm the expected output file exists and is non-empty.
2. Confirm SVG output starts with `<svg` or `<?xml`, or PNG output is reported as `PNG image data` by `file`.
3. Confirm every generated artifact (`.puml`, `.png`, `.svg`, `.atxt`, `.html`) is under the current project or `$PLANTUML_QPR_RENDER_DIR`.
4. If any artifact lands outside the controlled artifact root, move the source into the controlled root, delete only the out-of-bounds artifact created by this run, and re-render.
5. If the image is missing, read qpr stderr/stdout or PlantUML CLI output and fix the source, path, Docker, or include issue.
6. If PlantUML renders an error image, inspect the source around the reported line and retry.
7. If external includes fail, prefer PlantUML's standard library syntax or local includes over brittle network dependencies.
8. For C4 diagrams, preserve `!include <C4/...>` directives unless the runtime proves they are unavailable.

Read `references/troubleshooting.md` for common failures and fixes.

## Step 6: Respond to the User

Use this output structure:

1. **Preview**: Embed the rendered SVG/PNG with a Markdown image tag when the runtime supports it; otherwise give the absolute output path.
2. **Files**: List the controlled artifact root, `.puml` source, rendered image paths, and HTML wrapper path if one was generated.
3. **Render Mode**: State which method was used: qpr chat preview, qpr terminal watch, qpr plus fswatch, or PlantUML CLI fallback.
4. **Status**: Say whether the render succeeded, what was changed, and whether any watch process is still running.
5. **Next Edit**: If useful, mention the smallest next diagram edit the user might want.

Keep the response short. The image is the main artifact.

## Reference Files

- `references/qpr-commands.md` -- qpr install, render, server, watch, and preview command recipes
- `references/troubleshooting.md` -- Docker, watch mode, Kitty, include, and output-path fixes
