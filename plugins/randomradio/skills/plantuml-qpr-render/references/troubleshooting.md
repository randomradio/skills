# Troubleshooting qpr PlantUML Preview

Use this reference when qpr fails, produces no image, or cannot provide live preview in the current runtime.

## qpr Missing

Symptom:

```text
QPR_MISSING
```

Fix:

1. Install qpr workspace-locally with the commands in `qpr-commands.md`.
2. Export the local bin path in the same shell where render commands run.
3. Re-run `"$QPR" --help` before rendering.

Do not write to `/usr/local/bin`, `~/.local/bin`, or another global path unless the user explicitly asks.

## Docker Unavailable

Symptoms:

```text
DOCKER_UNAVAILABLE
Cannot connect to the Docker daemon
```

Fix:

1. Check whether Docker Desktop or the Docker daemon is running.
2. If Docker cannot be started in this environment, try `plantuml "-t$OUTPUT_FORMAT"` only if the local PlantUML CLI exists.
3. If no renderer is available, save the `.puml` source and give qpr setup steps instead of pretending the render succeeded.

## qpr Prompts for Docker Image Pull

Symptom:

```text
Docker image 'plantuml/plantuml:latest' not found locally.
Do you want to pull it now? [y/N]
```

Fix:

Pre-pull before running qpr:

```bash
docker pull plantuml/plantuml:latest
```

For server mode:

```bash
docker pull plantuml/plantuml-server:jetty
```

## Watch Mode Fails on macOS

Symptom:

```text
Error: 'inotifywait' command not found. Required for --watch.
```

Cause:

qpr's built-in `--watch` uses `inotifywait`, which is usually available on Linux but not macOS.

Fix:

1. Prefer agent-managed re-render and Markdown image previews in Codex/Claude sessions.
2. If a local watch loop is needed and `fswatch` is installed, use the `fswatch` recipe in `qpr-commands.md`.
3. If the user wants true qpr watch mode, explain that it needs `inotifywait`.

## Kitty Preview Fails

Symptoms:

```text
Error: 'kitten' command not found. Required for --print.
```

Fix:

1. Do not use `--print` unless `kitten` is detected.
2. Use qpr chat preview instead: render the selected SVG/PNG and embed the absolute path in Markdown.
3. If the user specifically wants terminal graphics, ask them to run in Kitty or install Kitty's command-line tools.

## SVG Preview Fails

Symptoms:

```text
The render succeeded, but the chat UI does not display the SVG inline.
```

Fix:

1. Verify the SVG exists, is non-empty, and starts with `<svg` or `<?xml`.
2. Provide the absolute SVG path even if inline display fails.
3. If the user needs an inline raster preview, run `plantuml-skill setup .png` or perform a one-off `"$QPR" --png --quiet "$PUML_FILE"` render.

## Output File Missing

Check these in order:

1. The source file path exists and ends in `.puml`.
2. The source file is under the current project or `$PLANTUML_QPR_RENDER_DIR`.
3. qpr rendered the same basename beside the source file.
4. The source file is inside a writable directory.
5. Docker can mount the source directory.
6. The output format matches the expected extension: `.png`, `.svg`, or `.atxt`.

Verification command:

```bash
OUTPUT_FILE="${PUML_FILE%.puml}${OUTPUT_EXT}"
ls -l "$PUML_FILE" "$OUTPUT_FILE"
```

## Artifact Outside Controlled Directory

Symptom:

```text
Rendered file landed outside the project preview directory or global render directory.
```

Cause:

qpr writes output beside the `.puml` source. The source was rendered from an uncontrolled location.

Fix:

1. Copy the `.puml` file into the controlled artifact root.
2. Re-run qpr on that controlled copy.
3. Delete only the out-of-bounds artifact created by the current run.
4. Report the controlled artifact root in the final response.

## PlantUML Error Image

PlantUML may produce an image that contains a syntax error message.

Fix:

1. Read the line number in the error image or qpr output.
2. Check missing `@startuml`, `@enduml`, unmatched brackets, and invalid arrows first.
3. For C4 diagrams, verify the `!include <C4/...>` statement is intact.
4. Re-render after the smallest source edit that addresses the error.

## External Includes Fail

Symptoms:

```text
Cannot open URL
No such file or directory
```

Fix:

1. Prefer PlantUML standard library includes such as `!include <C4/C4_Context>`.
2. For custom includes, place files beside the diagram or in a stable relative include path.
3. Avoid adding network includes unless the environment has network access and the user asked for them.

## Server Port Conflict

Symptom:

```text
localhost:8080 unavailable or wrong service responds
```

Fix:

qpr server mode assumes `localhost:8080`. If that port is occupied, skip `--server` and use default qpr Docker rendering:

```bash
"$QPR" "$OUTPUT_FLAG" --quiet "$PUML_FILE"
```

## Long-Running Watch Process

If the agent starts `qpr --watch` or an `fswatch` loop:

1. Keep the process tied to the current task.
2. Stop it before the final response unless the user explicitly asked to leave it running.
3. In the final response, state whether any watch process remains active.
