#!/usr/bin/env node
import crypto from "node:crypto";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(__dirname, "..");
const skillsRoot = path.join(repoRoot, "plugins/randomradio/skills");
const manifestPath = path.join(skillsRoot, "upstream.json");

const args = process.argv.slice(2);
const checkOnly = args.includes("--check");
const allowMissingUpstream = args.includes("--allow-missing-upstream");
const requireUpstream = args.includes("--require-upstream");
const writeReportIndex = args.indexOf("--write-report");
const reportPath =
  writeReportIndex >= 0
    ? path.resolve(repoRoot, args[writeReportIndex + 1] || "docs/upstream/compound-engineering-skill-report.md")
    : null;

const allowedModes = new Set(["mirror", "fork", "inspired", "original"]);

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function expandHome(value) {
  if (!value) return value;
  if (value === "~") return os.homedir();
  if (value.startsWith("~/")) return path.join(os.homedir(), value.slice(2));
  return value;
}

function sha256(value) {
  return crypto.createHash("sha256").update(value).digest("hex");
}

function stripFrontmatter(source) {
  return source.replace(/^---\n[\s\S]*?\n---\n/, "");
}

function parseFrontmatter(source) {
  const match = source.match(/^---\n([\s\S]*?)\n---\n/);
  const out = {};
  if (!match) return out;
  match[1].split("\n").forEach((line) => {
    const keyMatch = line.match(/^([A-Za-z0-9_-]+):\s*(.*)$/);
    if (!keyMatch) return;
    out[keyMatch[1]] = keyMatch[2].trim().replace(/^["']|["']$/g, "");
  });
  return out;
}

function normalizeLines(source) {
  return stripFrontmatter(source)
    .split(/\n+/)
    .map((line) => line.trim().replace(/\s+/g, " ").toLowerCase())
    .filter(Boolean);
}

function similarity(left, right) {
  const leftSet = new Set(normalizeLines(left));
  const rightSet = new Set(normalizeLines(right));
  if (leftSet.size === 0 && rightSet.size === 0) return 1;
  const union = new Set([...leftSet, ...rightSet]);
  let intersection = 0;
  leftSet.forEach((line) => {
    if (rightSet.has(line)) intersection += 1;
  });
  return intersection / union.size;
}

function headings(source) {
  return stripFrontmatter(source)
    .split("\n")
    .map((line) => line.match(/^(#{1,3})\s+(.+)$/)?.[2]?.trim())
    .filter(Boolean);
}

function normalizeHeading(value) {
  return value.toLowerCase().replace(/[`*_]/g, "").replace(/\s+/g, " ").trim();
}

function uniqueHeadings(left, right, limit = 8) {
  const rightSet = new Set(right.map(normalizeHeading));
  return left.filter((heading) => !rightSet.has(normalizeHeading(heading))).slice(0, limit);
}

function localSkillIds() {
  return fs
    .readdirSync(skillsRoot, { withFileTypes: true })
    .filter((entry) => entry.isDirectory())
    .map((entry) => entry.name)
    .sort();
}

function upstreamSkillPath(manifest, entry) {
  if (!entry.provider || !entry.upstreamSkill) return null;
  const provider = manifest.providers?.[entry.provider];
  if (!provider) return null;
  const root = expandHome(process.env[provider.skillsRootEnv] || provider.defaultLocalRoot);
  return path.join(root, entry.upstreamSkill, "SKILL.md");
}

function compatibilityResult(entry, localSource, id, localMeta) {
  if (entry.mode === "original") {
    return { status: "repo-owned", missingMarkers: [], errors: [], requiredCount: 0 };
  }

  const errors = [];
  const compatibility = entry.localCompatibility;
  if (!compatibility) {
    errors.push("missing localCompatibility contract");
    return { status: "missing-contract", missingMarkers: [], errors, requiredCount: 0 };
  }

  if (localMeta.name !== `rr:${id}`) {
    errors.push(`frontmatter name must stay rr:${id}`);
  }

  if (!Array.isArray(compatibility.preserve) || compatibility.preserve.length === 0) {
    errors.push("localCompatibility.preserve must list local changes to keep");
  }

  if (!compatibility.syncStrategy) {
    errors.push("localCompatibility.syncStrategy is required");
  }

  const requiredMarkers = compatibility.requiredMarkers || [];
  const missingMarkers = requiredMarkers.filter((marker) => !localSource.includes(marker));
  missingMarkers.forEach((marker) => errors.push(`missing required local marker: ${marker}`));

  return {
    status: errors.length ? "failed" : "passed",
    missingMarkers,
    errors,
    requiredCount: requiredMarkers.length,
  };
}

function syncDecision(result) {
  if (result.status === "repo-owned") return "update in repo";
  if (result.status === "missing-upstream") return "blocked: upstream unavailable";
  if (result.compatibility.status !== "passed") return "blocked: local contract failed";
  if (result.status === "in-sync") return "safe: already aligned";
  return "review upstream, preserve local contract";
}

function validateManifest(manifest, ids) {
  const errors = [];
  if (manifest.schemaVersion !== "2026-07-06.upstream-skills.v2") {
    errors.push(`Unexpected schemaVersion: ${manifest.schemaVersion || "(missing)"}`);
  }

  const manifestIds = Object.keys(manifest.skills || {}).sort();
  ids.forEach((id) => {
    if (!manifest.skills?.[id]) errors.push(`Missing upstream manifest entry for ${id}`);
  });
  manifestIds.forEach((id) => {
    if (!ids.includes(id)) errors.push(`Manifest entry ${id} has no local skill directory`);
  });

  manifestIds.forEach((id) => {
    const entry = manifest.skills[id];
    if (!allowedModes.has(entry.mode)) {
      errors.push(`${id} has invalid mode ${entry.mode || "(missing)"}`);
    }
    if (entry.upstreamSkill && !entry.provider) {
      errors.push(`${id} has upstreamSkill but no provider`);
    }
    if (entry.provider && !manifest.providers?.[entry.provider]) {
      errors.push(`${id} references unknown provider ${entry.provider}`);
    }
    if (entry.mode !== "original" && !entry.localCompatibility) {
      errors.push(`${id} is ${entry.mode} but has no localCompatibility contract`);
    }
  });

  return errors;
}

function compareSkill(manifest, id) {
  // Missing entries are reported by validateManifest; don't crash before that.
  const entry = manifest.skills[id] ?? { mode: "original" };
  const localPath = path.join(skillsRoot, id, "SKILL.md");
  const localSource = fs.readFileSync(localPath, "utf8");
  const localMeta = parseFrontmatter(localSource);
  const upstreamPath = upstreamSkillPath(manifest, entry);
  const compatibility = compatibilityResult(entry, localSource, id, localMeta);
  const base = {
    id,
    mode: entry.mode,
    provider: entry.provider || "",
    providerName: entry.provider ? manifest.providers[entry.provider].displayName : "",
    upstreamSkill: entry.upstreamSkill || "",
    updatePolicy: entry.updatePolicy || "",
    localPath: path.relative(repoRoot, localPath),
    upstreamPath: upstreamPath || "",
    localName: localMeta.name || "",
    upstreamName: "",
    localHash: sha256(localSource).slice(0, 12),
    upstreamHash: "",
    similarity: null,
    status: entry.upstreamSkill ? "missing-upstream" : "repo-owned",
    compatibility,
    syncDecision: "",
    preserve: entry.localCompatibility?.preserve || [],
    requiredMarkers: entry.localCompatibility?.requiredMarkers || [],
    localOnlyHeadings: [],
    upstreamOnlyHeadings: [],
  };
  base.syncDecision = syncDecision(base);

  if (!upstreamPath) return base;
  if (!fs.existsSync(upstreamPath)) return base;

  const upstreamSource = fs.readFileSync(upstreamPath, "utf8");
  const upstreamMeta = parseFrontmatter(upstreamSource);
  const upstreamHash = sha256(upstreamSource).slice(0, 12);
  const localHash = sha256(localSource).slice(0, 12);
  const score = similarity(localSource, upstreamSource);
  const localHeadings = headings(localSource);
  const upstreamHeadings = headings(upstreamSource);

  const result = {
    ...base,
    upstreamName: upstreamMeta.name || "",
    upstreamHash,
    similarity: score,
    status: localHash === upstreamHash ? "in-sync" : "diverged",
    localOnlyHeadings: uniqueHeadings(localHeadings, upstreamHeadings),
    upstreamOnlyHeadings: uniqueHeadings(upstreamHeadings, localHeadings),
  };
  result.syncDecision = syncDecision(result);
  return result;
}

function percent(value) {
  return value == null ? "" : `${Math.round(value * 100)}%`;
}

function markdownReport(manifest, results, errors) {
  const now = new Date().toISOString();
  const rows = results
    .map((result) =>
      [
        result.id,
        result.mode,
        result.providerName || "-",
        result.upstreamSkill || "-",
        result.status,
        percent(result.similarity) || "-",
        result.compatibility.status,
        result.updatePolicy || "-",
        result.syncDecision,
      ].join(" | "),
    )
    .map((row) => `| ${row} |`)
    .join("\n");
  const details = results
    .filter((result) => result.upstreamSkill)
    .map((result) => {
      const preserve = result.preserve.length
        ? result.preserve.map((item) => `- ${item}`).join("\n")
        : "- No local preservation notes.";
      const missing = result.compatibility.missingMarkers.length
        ? result.compatibility.missingMarkers.map((item) => `- ${item}`).join("\n")
        : "- None.";
      const localOnly = result.localOnlyHeadings.length
        ? result.localOnlyHeadings.map((item) => `- ${item}`).join("\n")
        : "- None in first-pass heading comparison.";
      const upstreamOnly = result.upstreamOnlyHeadings.length
        ? result.upstreamOnlyHeadings.map((item) => `- ${item}`).join("\n")
        : "- None in first-pass heading comparison.";

      return `### ${result.id}

| Field | Value |
|---|---|
| Local name | \`${result.localName || "-"}\` |
| Upstream name | \`${result.upstreamName || result.upstreamSkill}\` |
| Local hash | \`${result.localHash}\` |
| Upstream hash | \`${result.upstreamHash || "-"}\` |
| Compatibility | ${result.compatibility.status} |
| Sync decision | ${result.syncDecision} |

Preserve:

${preserve}

Missing required markers:

${missing}

Local-only headings:

${localOnly}

Upstream-only headings:

${upstreamOnly}
`;
    })
    .join("\n");

  const contracts = (manifest.localContracts || []).map((item) => `- ${item}`).join("\n");
  const problems = errors.length
    ? errors.map((error) => `- ${error}`).join("\n")
    : "- None.";

  return `# Compound Engineering Skill Lineage

Generated: ${now}

This report compares published RandomRadio skills against configured upstream
skills when the upstream skills are installed locally. RandomRadio remains the
source of record; upstream is a comparison source for selective non-breaking
updates.

## Local Contracts

${contracts}

## Status

| Skill | Mode | Provider | Upstream skill | Status | Similarity | Compatibility | Update policy | Sync decision |
|---|---|---|---|---|---:|---|---|---|
${rows}

## Skill Deltas

${details}

## Validation

${problems}

## Update Rule

For "fork" skills, compare upstream first, adopt upstream improvements by
default, and preserve local contracts explicitly. If a local divergence should
remain, document why in the skill or in the implementation commit.
`;
}

const manifest = readJson(manifestPath);
const ids = localSkillIds();
const errors = validateManifest(manifest, ids);
const results = ids.map((id) => compareSkill(manifest, id));
results.forEach((result) => {
  result.compatibility.errors.forEach((error) => errors.push(`${result.id}: ${error}`));
});

if (requireUpstream && !allowMissingUpstream) {
  results
    .filter((result) => result.status === "missing-upstream")
    .forEach((result) => errors.push(`${result.id} missing upstream at ${result.upstreamPath}`));
}

if (reportPath) {
  fs.mkdirSync(path.dirname(reportPath), { recursive: true });
  fs.writeFileSync(reportPath, markdownReport(manifest, results, errors));
  console.log(`Wrote ${path.relative(repoRoot, reportPath)}`);
}

if (!checkOnly && !reportPath) {
  console.table(
    results.map((result) => ({
      skill: result.id,
      mode: result.mode,
      upstream: result.upstreamSkill || "-",
      status: result.status,
      similarity: percent(result.similarity) || "-",
      compatibility: result.compatibility.status,
      decision: result.syncDecision,
    })),
  );
}

if (errors.length) {
  errors.forEach((error) => console.error(`[upstream] ${error}`));
  process.exit(1);
}

if (checkOnly) {
  console.log(`[upstream] ${ids.length} skill provenance entries validated`);
}
