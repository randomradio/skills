#!/usr/bin/env python3
"""
package.py — validate and package skills into dist/, with no third-party deps.

A self-contained stand-in for the skill-creator's quick_validate.py + package_skill.py
that needs neither pyyaml nor a newer Python (works on the stock macOS python3). A
.skill file is just a ZIP_DEFLATED archive whose top-level entry is the skill folder.

Usage:
    python3 package.py                 # validate + package every skill into ./dist
    python3 package.py trade-planner   # just the named skill(s)

Frontmatter is parsed pragmatically (enough for skill frontmatter: scalar keys, one
folded/literal block scalar, an optional nested metadata mapping, an optional list),
not by a general YAML engine — which is exactly why pyyaml isn't required.
"""
import fnmatch
import sys
import zipfile
from pathlib import Path

ALLOWED_PROPERTIES = {"name", "description", "license", "allowed-tools", "metadata", "compatibility"}
EXCLUDE_DIRS = {"__pycache__", "node_modules"}
ROOT_EXCLUDE_DIRS = {"evals"}
EXCLUDE_GLOBS = {"*.pyc"}
EXCLUDE_FILES = {".DS_Store"}


def parse_frontmatter(text):
    """Parse a skill's YAML frontmatter into a dict using only the stdlib."""
    lines = text.split("\n")
    data, i, n = {}, 0, len(lines)
    while i < n:
        line = lines[i]
        if not line.strip() or line.lstrip().startswith("#") or line[0] in (" ", "\t") or ":" not in line:
            i += 1
            continue
        key, rest = line.split(":", 1)
        key, rest = key.strip(), rest.strip()
        if rest in (">-", ">", ">+", "|", "|-", "|+"):  # block scalar
            block, i = [], i + 1
            while i < n and (lines[i].strip() == "" or lines[i][:1] in (" ", "\t")):
                block.append(lines[i].strip())
                i += 1
            data[key] = ("\n".join(block).strip("\n") if rest.startswith("|")
                         else " ".join(s for s in block if s))
            continue
        if rest == "":  # nested mapping or list
            nested, items, i = {}, [], i + 1
            while i < n and (lines[i].strip() == "" or lines[i][:1] in (" ", "\t")):
                s = lines[i].strip()
                if s.startswith("- "):
                    items.append(s[2:].strip())
                elif ":" in s:
                    k2, v2 = s.split(":", 1)
                    nested[k2.strip()] = v2.strip()
                i += 1
            data[key] = items if items else nested
            continue
        if len(rest) >= 2 and rest[0] == rest[-1] and rest[0] in "\"'":
            rest = rest[1:-1]
        data[key] = rest
        i += 1
    return data


def validate_skill(skill_path):
    """Return (ok, message). Mirrors the checks in skill-creator/quick_validate.py."""
    skill_md = skill_path / "SKILL.md"
    if not skill_md.exists():
        return False, "SKILL.md not found"

    def packaged(rel):
        parts = rel.parts[:-1]
        return not (any(p in EXCLUDE_DIRS for p in parts) or (parts and parts[0] in ROOT_EXCLUDE_DIRS))

    extra = [p for p in skill_path.rglob("SKILL.md") if packaged(p.relative_to(skill_path)) and p != skill_md]
    if extra:
        return False, f"Multiple SKILL.md files (a skill must have exactly one): extra {[str(p) for p in extra]}"

    text = skill_md.read_text()
    if not text.startswith("---"):
        return False, "No YAML frontmatter found"
    end = text.find("\n---", 3)
    if end == -1:
        return False, "Invalid frontmatter format"
    fm = parse_frontmatter(text[3:end])

    unexpected = set(fm) - ALLOWED_PROPERTIES
    if unexpected:
        return False, f"Unexpected frontmatter key(s): {', '.join(sorted(unexpected))}"
    for req in ("name", "description"):
        if req not in fm:
            return False, f"Missing '{req}' in frontmatter"

    name = (fm["name"] or "").strip()
    if not all(c.islower() or c.isdigit() or c == "-" for c in name) or not name:
        return False, f"Name '{name}' should be kebab-case (lowercase letters, digits, hyphens)"
    if name.startswith("-") or name.endswith("-") or "--" in name or len(name) > 64:
        return False, f"Name '{name}' is malformed or too long"
    if name != skill_path.name:
        return False, f"Name '{name}' does not match folder '{skill_path.name}'"

    desc = (fm["description"] or "").strip()
    if "<" in desc or ">" in desc:
        return False, "Description cannot contain angle brackets (< or >)"
    if len(desc) > 1024:
        return False, f"Description too long ({len(desc)} > 1024)"
    if len(fm.get("compatibility", "") or "") > 500:
        return False, "Compatibility too long (> 500)"
    return True, "valid"


def should_exclude(rel):
    parts = rel.parts
    if any(p in EXCLUDE_DIRS for p in parts):
        return True
    if len(parts) > 1 and parts[1] in ROOT_EXCLUDE_DIRS:
        return True
    return rel.name in EXCLUDE_FILES or any(fnmatch.fnmatch(rel.name, g) for g in EXCLUDE_GLOBS)


def package(skill_path, dist):
    out = dist / f"{skill_path.name}.skill"
    count = 0
    with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
        for fp in sorted(skill_path.rglob("*")):
            if not fp.is_file():
                continue
            arc = fp.relative_to(skill_path.parent)
            if should_exclude(arc):
                continue
            z.write(fp, arc)
            count += 1
    return out, count


def main():
    root = Path(__file__).resolve().parent
    dist = root / "dist"
    dist.mkdir(exist_ok=True)
    names = sys.argv[1:] or sorted(p.parent.name for p in root.glob("*/SKILL.md"))
    failures = 0
    for nm in names:
        sp = (root / nm).resolve()
        ok, msg = validate_skill(sp)
        if not ok:
            print(f"  SKIP  {nm}: {msg}")
            failures += 1
            continue
        out, n = package(sp, dist)
        print(f"  OK    {nm}  ->  {out.relative_to(root)}  ({n} file{'s' if n != 1 else ''})")
    print(f"\n{len(names) - failures}/{len(names)} packaged into {dist.relative_to(root)}/")
    sys.exit(1 if failures else 0)


if __name__ == "__main__":
    main()
