const state = {
  registry: null,
  category: "All",
  query: "",
  sort: "featured",
};

const els = {
  search: document.querySelector("#skill-search"),
  filters: document.querySelector("#filters"),
  grid: document.querySelector("#skill-grid"),
  template: document.querySelector("#skill-card-template"),
  summary: document.querySelector("#catalog-summary"),
  empty: document.querySelector("#empty-state"),
  sort: document.querySelector("#sort-select"),
};

const iconText = {
  Workflow: "↻",
  Quality: "✓",
  Git: "⌁",
  Knowledge: "◆",
  Productivity: "·",
  Deployment: "⇡",
  Diagrams: "▧",
  Utilities: "⋯",
};

async function loadRegistry() {
  const response = await fetch("./registry.json", { cache: "no-store" });
  if (!response.ok) throw new Error(`Unable to load registry: ${response.status}`);
  state.registry = await response.json();
  hydrateShell();
  renderFilters();
  renderSkills();
}

function hydrateShell() {
  const { collection, commands } = state.registry;
  document.querySelector("#skill-count").textContent = collection.skillCount;
  document.querySelector("#stat-skills").textContent = collection.skillCount;
  document.querySelector("#stat-agents").textContent = collection.agentCount;
  document.querySelector("#stat-version").textContent = collection.version;
  document.querySelector("#cmd-install-codex").textContent = commands.installCodex;
  document.querySelector("#cmd-install-claude").textContent = commands.installClaude;
  document.querySelector("#cmd-update").textContent = commands.update;

  document.querySelectorAll("[data-copy]").forEach((button) => {
    button.addEventListener("click", () => copyCommand(button.dataset.copy, button));
  });

  document.querySelectorAll("[data-search]").forEach((button) => {
    button.addEventListener("click", () => {
      els.search.value = button.dataset.search;
      state.query = button.dataset.search;
      renderSkills();
    });
  });
}

function categories() {
  const counts = new Map([["All", state.registry.skills.length]]);
  state.registry.skills.forEach((skill) => {
    counts.set(skill.category, (counts.get(skill.category) || 0) + 1);
  });
  return [...counts.entries()].sort(([a], [b]) => {
    if (a === "All") return -1;
    if (b === "All") return 1;
    return a.localeCompare(b);
  });
}

function renderFilters() {
  els.filters.replaceChildren();
  categories().forEach(([category, count]) => {
    const button = document.createElement("button");
    button.className = "filter-button";
    button.type = "button";
    button.dataset.category = category;
    button.append(category, metaPill(count));
    button.classList.toggle("is-active", category === state.category);
    button.addEventListener("click", () => {
      state.category = category;
      renderFilters();
      renderSkills();
    });
    els.filters.append(button);
  });
}

function filteredSkills() {
  const normalizedQuery = state.query.trim().toLowerCase();
  return state.registry.skills
    .filter((skill) => state.category === "All" || skill.category === state.category)
    .filter((skill) => {
      if (!normalizedQuery) return true;
      return [
        skill.id,
        skill.name,
        skill.title,
        skill.category,
        skill.description,
        ...(skill.tags || []),
      ]
        .join(" ")
        .toLowerCase()
        .includes(normalizedQuery);
    })
    .sort((a, b) => {
      if (state.sort === "featured") {
        if (a.featured !== b.featured) return a.featured ? -1 : 1;
        return a.title.localeCompare(b.title);
      }
      if (state.sort === "category") {
        return `${a.category}-${a.title}`.localeCompare(`${b.category}-${b.title}`);
      }
      return a.title.localeCompare(b.title);
    });
}

function renderSkills() {
  const skills = filteredSkills();
  els.grid.replaceChildren();
  els.empty.hidden = skills.length > 0;
  els.summary.textContent = `${skills.length} of ${state.registry.skills.length} skills shown`;

  skills.forEach((skill) => {
    const card = els.template.content.firstElementChild.cloneNode(true);
    card.classList.toggle("is-featured", skill.featured);
    card.querySelector(".skill-icon").textContent = iconText[skill.category] || "·";
    card.querySelector("h3").textContent = skill.title;
    card.querySelector(".skill-category").textContent = skill.category;
    card.querySelector(".skill-description").textContent = skill.description;
    card.querySelector(".meta-line").replaceChildren(
      metaPill(skill.name),
      metaPill(`v${skill.version}`),
      metaPill(skill.versionScope),
    );

    const copyButton = card.querySelector(".copy-id");
    copyButton.addEventListener("click", () => copyText(skill.name, copyButton, "Copied"));

    const sourceLink = card.querySelector(".source-link");
    sourceLink.href = skill.sourceUrl;
    sourceLink.target = "_blank";
    sourceLink.rel = "noreferrer";
    sourceLink.textContent = "Source";

    els.grid.append(card);
  });
}

function metaPill(text) {
  const span = document.createElement("span");
  span.textContent = text;
  return span;
}

function copyCommand(key, button) {
  const value = state.registry?.commands?.[key];
  if (value) copyText(value, button, "Copied");
}

async function copyText(value, button, copiedLabel) {
  const label = button.querySelector("[data-copy-label]") || button;
  const previous = label.textContent;
  try {
    await navigator.clipboard.writeText(value);
    label.textContent = copiedLabel;
  } catch {
    label.textContent = "Copy manually";
  }
  setTimeout(() => {
    label.textContent = previous;
  }, 1200);
}

els.search.addEventListener("input", (event) => {
  state.query = event.target.value;
  renderSkills();
});

els.sort.addEventListener("change", (event) => {
  state.sort = event.target.value;
  renderSkills();
});

window.addEventListener("keydown", (event) => {
  if (event.key === "/" && document.activeElement !== els.search) {
    event.preventDefault();
    els.search.focus();
  }
});

loadRegistry().catch((error) => {
  els.summary.textContent = error.message;
  els.empty.hidden = false;
});
