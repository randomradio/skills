# qpr Command Recipes

This reference contains copy-paste commands for using `qpr` as the preferred PlantUML renderer. Always trust runtime detection and `"$QPR" --help` if this reference and the installed qpr version disagree.

## Controlled Artifact Directory

qpr writes outputs beside the `.puml` source. To keep PNG, SVG, text, and optional HTML preview files controlled, always render a source file that already lives under one of these roots:

1. `$PLANTUML_QPR_RENDER_DIR` if explicitly set and writable.
2. `outputs/plantuml-preview/` in the current project when that directory exists.
3. `work/plantuml-preview/` in the current project.
4. `.plantuml-preview/` in the current project.

Use this shell pattern to choose a root:

```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
if [ -n "$PLANTUML_QPR_RENDER_DIR" ]; then
  PREVIEW_ROOT="$PLANTUML_QPR_RENDER_DIR"
elif [ -d "$PROJECT_ROOT/outputs" ]; then
  PREVIEW_ROOT="$PROJECT_ROOT/outputs/plantuml-preview"
elif [ -d "$PROJECT_ROOT/work" ]; then
  PREVIEW_ROOT="$PROJECT_ROOT/work/plantuml-preview"
else
  PREVIEW_ROOT="$PROJECT_ROOT/.plantuml-preview"
fi
mkdir -p "$PREVIEW_ROOT"
```

Create each diagram in its own subdirectory:

```bash
SLUG="diagram-preview"
DIAGRAM_DIR="$PREVIEW_ROOT/$SLUG"
mkdir -p "$DIAGRAM_DIR"
PUML_FILE="$DIAGRAM_DIR/$SLUG.puml"
```

If the user's source file is outside the current project and outside `$PLANTUML_QPR_RENDER_DIR`, copy it into `DIAGRAM_DIR` and render the copy.

## Install qpr Workspace-Locally

Use a workspace-local install by default. It avoids global writes and works well in agent sessions.

```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
QPR_COMMIT="990ba04fe9ca17593aa126f9bd825c820cfeec97"
QPR_SHA256="555c2ad6705818edb3156d9bbc155953c5814bb9142a0566d717bd07cc4cbd67"
QPR="$PROJECT_ROOT/.tools/bin/qpr"
mkdir -p "$PROJECT_ROOT/.tools/bin"
curl -fsSL "https://raw.githubusercontent.com/hwblx/qpr/$QPR_COMMIT/qpr" -o "$QPR"
printf '%s  %s\n' "$QPR_SHA256" "$QPR" | shasum -a 256 -c -
chmod +x "$QPR"
```

If `curl` is unavailable:

```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
QPR_COMMIT="990ba04fe9ca17593aa126f9bd825c820cfeec97"
QPR="$PROJECT_ROOT/.tools/bin/qpr"
mkdir -p "$PROJECT_ROOT/.tools/bin" "$PROJECT_ROOT/.tools/qpr"
if ! git -C "$PROJECT_ROOT/.tools/qpr" rev-parse --git-dir >/dev/null 2>&1; then
  git -C "$PROJECT_ROOT/.tools/qpr" init
  git -C "$PROJECT_ROOT/.tools/qpr" remote add origin https://github.com/hwblx/qpr.git
fi
git -C "$PROJECT_ROOT/.tools/qpr" fetch --depth 1 origin "$QPR_COMMIT"
git -C "$PROJECT_ROOT/.tools/qpr" checkout --detach FETCH_HEAD
ln -sf "$PROJECT_ROOT/.tools/qpr/qpr" "$QPR"
```

## Prepare Docker Images

qpr uses Docker and may prompt before pulling images. Pre-pull images in agent sessions so render commands do not block.

```bash
docker image inspect plantuml/plantuml:latest >/dev/null 2>&1 || docker pull plantuml/plantuml:latest
```

For repeated renders or watch sessions, qpr can use a local PlantUML server:

```bash
docker image inspect plantuml/plantuml-server:jetty >/dev/null 2>&1 || docker pull plantuml/plantuml-server:jetty
```

## One-Off Chat Preview

Render PNG beside the controlled `.puml` source:

```bash
"$QPR" --png --quiet "$PUML_FILE"
```

Verify:

```bash
PNG_FILE="${PUML_FILE%.puml}.png"
test -s "$PNG_FILE" && echo "RENDER_OK $PNG_FILE" || echo "RENDER_MISSING"
```

In Codex desktop or another local chat UI that supports local images, embed the absolute image path:

```markdown
![PlantUML preview](/absolute/path/to/diagram.png)
```

## SVG and Text Outputs

Use SVG when the user wants a scalable asset:

```bash
"$QPR" --svg --quiet "$PUML_FILE"
```

Use text when image display is unavailable:

```bash
"$QPR" --txt --quiet "$PUML_FILE"
cat "${PUML_FILE%.puml}.atxt"
```

## Optional HTML Preview Wrapper

qpr does not need HTML to render PlantUML. If the user asks for an HTML preview page, write the wrapper beside the controlled render output:

```bash
HTML_FILE="$DIAGRAM_DIR/index.html"
```

The HTML file should reference only artifacts in `DIAGRAM_DIR`, for example `./diagram-preview.png`. Do not write preview HTML into `/tmp`, the home directory, or another ad hoc location.

## qpr Terminal Preview

Requires Kitty's `kitten` command:

```bash
"$QPR" --print --quiet "$PUML_FILE"
```

For an in-place grid preview with qpr watch:

```bash
"$QPR" --server --grid=1x1 --watch "$PUML_FILE"
```

For multiple diagrams:

```bash
"$QPR" --server --grid=2x2 --watch "$DIAGRAM_DIR/diagram-prefix"
```

## macOS Watch Loop

qpr's built-in `--watch` uses `inotifywait`, which is commonly missing on macOS. If `fswatch` is available, keep qpr as the renderer and let `fswatch` trigger re-renders:

```bash
"$QPR" --png --quiet "$PUML_FILE"
while fswatch -1 "$PUML_FILE"; do
  "$QPR" --png --quiet "$PUML_FILE"
done
```

With Kitty terminal graphics:

```bash
"$QPR" --print --quiet "$PUML_FILE"
while fswatch -1 "$PUML_FILE"; do
  "$QPR" --print --quiet "$PUML_FILE"
done
```

## Server Mode

Use server mode for repeated renders:

```bash
"$QPR" --server --png --quiet "$PUML_FILE"
```

qpr targets `localhost:8080` for server mode. If another service is using that port, avoid `--server` and use the default Docker image render path.

## Output Rules

- `"$QPR" --png` writes `diagram.png` beside `diagram.puml`.
- `"$QPR" --svg` writes `diagram.svg` beside `diagram.puml`.
- `"$QPR" --txt` writes `diagram.atxt` beside `diagram.puml`.
- qpr accepts full `.puml` filenames or filename prefixes.
- Prefix mode renders matching `.puml` files in the same directory.
- Optional HTML wrappers must be created in the same controlled diagram directory.
