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

function validateManifest(manifest, ids) {
  const errors = [];
  if (manifest.schemaVersion !== "2026-07-06.upstream-skills.v1") {
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
  });

  return errors;
}

function compareSkill(manifest, id) {
  const entry = manifest.skills[id];
  const localPath = path.join(skillsRoot, id, "SKILL.md");
  const localSource = fs.readFileSync(localPath, "utf8");
  const upstreamPath = upstreamSkillPath(manifest, entry);
  const base = {
    id,
    mode: entry.mode,
    provider: entry.provider || "",
    providerName: entry.provider ? manifest.providers[entry.provider].displayName : "",
    upstreamSkill: entry.upstreamSkill || "",
    updatePolicy: entry.updatePolicy || "",
    localPath: path.relative(repoRoot, localPath),
    upstreamPath: upstreamPath || "",
    localHash: sha256(localSource).slice(0, 12),
    upstreamHash: "",
    similarity: null,
    status: entry.upstreamSkill ? "missing-upstream" : "repo-owned",
  };

  if (!upstreamPath) return base;
  if (!fs.existsSync(upstreamPath)) return base;

  const upstreamSource = fs.readFileSync(upstreamPath, "utf8");
  const upstreamHash = sha256(upstreamSource).slice(0, 12);
  const localHash = sha256(localSource).slice(0, 12);
  const score = similarity(localSource, upstreamSource);

  return {
    ...base,
    upstreamHash,
    similarity: score,
    status: localHash === upstreamHash ? "in-sync" : "diverged",
  };
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
        result.updatePolicy || "-",
      ].join(" | "),
    )
    .map((row) => `| ${row} |`)
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

| Skill | Mode | Provider | Upstream skill | Status | Similarity | Update policy |
|---|---|---|---|---|---:|---|
${rows}

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
