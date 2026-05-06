# Principles

1. The code repository is the single source of record: any knowledge that is not in the repo does not exist for the agent. Discussions, decisions held in people’s heads, external documents—if they affect development, they must be committed as versioned artifacts inside the repo.
2. This file is a map, not an encyclopedia: keep it to around 100 lines and point to deeper material in docs/. Each layer should expose only the information for that layer plus the navigation to the next step.
3. Encode taste as rules: prefer enforcing constraints through linters, structural tests, and CI checks rather than natural-language instructions. Mechanically verifiable rules are better than prose guidance.
4. Plans are first-class artifacts: execution plans, along with progress logs, should be versioned and stored centrally in docs/plans/.
5. Continuous garbage collection: repay technical debt in small, ongoing increments rather than letting it accumulate into a large cleanup. Track gaps in docs/plans/tech-debt-tracker.md.
6. When stuck, fix the environment instead of pushing harder: when an agent runs into difficulty, ask, “What context, tools, or constraints are missing?” and then add them to the repo.
