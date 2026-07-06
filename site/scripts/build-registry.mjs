#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(__dirname, "../..");
const pluginRoot = path.join(repoRoot, "plugins/randomradio");
const skillsRoot = path.join(pluginRoot, "skills");
const agentsRoot = path.join(pluginRoot, "agents");
const siteRoot = path.join(repoRoot, "site");
const registryPath = path.join(siteRoot, "registry.json");
const pluginManifest = JSON.parse(
  fs.readFileSync(path.join(pluginRoot, ".claude-plugin/plugin.json"), "utf8"),
);
const upstreamManifestPath = path.join(skillsRoot, "upstream.json");
const upstreamManifest = fs.existsSync(upstreamManifestPath)
  ? JSON.parse(fs.readFileSync(upstreamManifestPath, "utf8"))
  : { providers: {}, skills: {} };
const existingRegistry = fs.existsSync(registryPath)
  ? JSON.parse(fs.readFileSync(registryPath, "utf8"))
  : {};

const categoryById = new Map([
  ["brainstorm", "Workflow"],
  ["compound", "Knowledge"],
  ["compound-refresh", "Knowledge"],
  ["debug", "Quality"],
  ["document-review", "Quality"],
  ["git-commit", "Git"],
  ["git-commit-push-pr", "Git"],
  ["git-worktree", "Git"],
  ["ideate", "Workflow"],
  ["plan", "Workflow"],
  ["plantuml-qpr-render", "Diagrams"],
  ["quick-shoutout", "Deployment"],
  ["resolve-pr-feedback", "Git"],
  ["review", "Quality"],
  ["skills-market-publish", "Deployment"],
  ["tdd", "Quality"],
  ["todo-create", "Productivity"],
  ["todo-resolve", "Productivity"],
  ["todo-triage", "Productivity"],
  ["work", "Workflow"],
]);

const featuredIds = new Set([
  "work",
  "plan",
  "review",
  "debug",
  "plantuml-qpr-render",
  "skills-market-publish",
  "quick-shoutout",
]);

const titleWords = new Map([
  ["pr", "PR"],
  ["qpr", "qpr"],
  ["tdd", "TDD"],
  ["uml", "UML"],
  ["plantuml", "PlantUML"],
]);

function extractFrontmatter(source, filePath) {
  const match = source.match(/^---\n([\s\S]*?)\n---\n/);
  if (!match) {
    throw new Error(`Missing YAML frontmatter in ${filePath}`);
  }
  return match[1];
}

function parseFrontmatter(frontmatter) {
  const out = {};
  const lines = frontmatter.split("\n");

  for (let index = 0; index < lines.length; index += 1) {
    const line = lines[index];
    const keyMatch = line.match(/^([A-Za-z0-9_-]+):(?:\s*(.*))?$/);
    if (!keyMatch) continue;

    const [, key, rawValue = ""] = keyMatch;
    if (rawValue.trim() === ">") {
      const block = [];
      index += 1;
      while (index < lines.length && /^\s+/.test(lines[index])) {
        block.push(lines[index].trim());
        index += 1;
      }
      index -= 1;
      out[key] = block.join(" ").replace(/\s+/g, " ").trim();
      continue;
    }

    out[key] = rawValue.trim().replace(/^["']|["']$/g, "");
  }

  const tagMatch = frontmatter.match(/tags:\s*\[([^\]]+)\]/);
  out.tags = tagMatch
    ? tagMatch[1].split(",").map((tag) => tag.trim()).filter(Boolean)
    : [];

  return out;
}

function titleFromId(id) {
  return id
    .split("-")
    .map((part) => titleWords.get(part) || part.charAt(0).toUpperCase() + part.slice(1))
    .join(" ");
}

function categoryFor(id, description) {
  if (categoryById.has(id)) return categoryById.get(id);
  const haystack = `${id} ${description}`;
  if (/plantuml|diagram|uml|qpr/i.test(haystack)) return "Diagrams";
  if (/\bgit\b|commit|worktree|pull request/i.test(haystack)) return "Git";
  if (/review|debug|tdd|document/i.test(haystack)) return "Quality";
  if (/plan|brainstorm|ideate|workflow/i.test(haystack)) return "Workflow";
  if (/compound|knowledge|refresh/i.test(haystack)) return "Knowledge";
  if (/todo/i.test(haystack)) return "Productivity";
  if (/publish|cloudflare|deploy/i.test(haystack)) return "Deployment";
  return "Utilities";
}

function countAgents() {
  if (!fs.existsSync(agentsRoot)) return 0;
  return fs
    .readdirSync(agentsRoot, { withFileTypes: true })
    .filter((entry) => entry.isDirectory())
    .flatMap((entry) => {
      const dir = path.join(agentsRoot, entry.name);
      return fs.readdirSync(dir).filter((file) => file.endsWith(".md"));
    }).length;
}

const skillDirs = fs
  .readdirSync(skillsRoot, { withFileTypes: true })
  .filter((entry) => entry.isDirectory())
  .map((entry) => entry.name)
  .sort();

const skills = skillDirs.map((id) => {
  const skillPath = path.join(skillsRoot, id, "SKILL.md");
  const source = fs.readFileSync(skillPath, "utf8");
  const meta = parseFrontmatter(extractFrontmatter(source, skillPath));
  const description = meta.description || "";
  const upstreamEntry = upstreamManifest.skills?.[id] || { mode: "original" };
  const upstreamProvider = upstreamEntry.provider
    ? upstreamManifest.providers?.[upstreamEntry.provider]
    : null;

  return {
    id,
    name: meta.name || `rr:${id}`,
    title: titleFromId(id),
    category: categoryFor(id, description),
    description,
    version: meta.version || pluginManifest.version,
    versionScope: meta.version ? "skill" : "collection",
    tags: meta.tags,
    featured: featuredIds.has(id),
    path: path.relative(repoRoot, skillPath),
    sourceUrl: `${pluginManifest.repository}/blob/master/${path.relative(repoRoot, skillPath)}`,
    upstream: {
      mode: upstreamEntry.mode || "original",
      provider: upstreamEntry.provider || null,
      providerName: upstreamProvider?.displayName || null,
      upstreamSkill: upstreamEntry.upstreamSkill || null,
      updatePolicy: upstreamEntry.updatePolicy || null,
    },
  };
});

const registry = {
  schemaVersion: "2026-07-06.skills-market.v1",
  generatedAt:
    process.env.SKILLS_REGISTRY_GENERATED_AT ||
    existingRegistry.generatedAt ||
    new Date().toISOString(),
  homepage: "https://skills.icyzhao.com/",
  repository: pluginManifest.repository,
  collection: {
    name: pluginManifest.name,
    version: pluginManifest.version,
    description: pluginManifest.description,
    skillCount: skills.length,
    agentCount: countAgents(),
    upstreamTrackedCount: skills.filter((skill) => skill.upstream.upstreamSkill).length,
  },
  commands: {
    installAll:
      "curl -fsSL https://raw.githubusercontent.com/randomradio/skills/master/install.sh | bash -s -- --target all",
    installCodex:
      "curl -fsSL https://raw.githubusercontent.com/randomradio/skills/master/install.sh | bash -s -- --target codex",
    installClaude:
      "curl -fsSL https://raw.githubusercontent.com/randomradio/skills/master/install.sh | bash -s -- --target claude",
    update:
      "./randomradio-upgrade/scripts/upgrade_skills.sh --target all",
  },
  skills,
};

fs.mkdirSync(siteRoot, { recursive: true });
fs.writeFileSync(registryPath, `${JSON.stringify(registry, null, 2)}\n`);
console.log(`Wrote ${path.relative(repoRoot, registryPath)} with ${skills.length} skills`);
