# Benchmark — trade-discipline-suite (iteration 1)

| Config | Pass rate | Time (s) | Tokens |
|---|---|---|---|
| with_skill | 100% | 67.7 | 33211 |
| without_skill | 48% | 58.0 | 28785 |
| **delta** | **+0.52** | +9.7 | +4426 |

## Per-eval pass rate

| Eval | with_skill | without_skill |
|---|---|---|
| size-and-gate | 5/5 | 3/5 |
| weekly-scale | 6/6 | 3/6 |
| orchestrator-gate | 6/6 | 2/6 |

## Notes
- Single run per configuration: pass-rate deltas are directional, not statistically robust. Re-run 3x for stable stats.
- Non-discriminating assertions (pass in BOTH configs): reward:risk, share size, scale-up verdict, expectancy sign, rule-break rate, process-not-advice. A capable model reproduces these unaided.
- Discriminating assertions (the skill's real value-add): ran the bundled script (reproducible math vs hand-calc), the profit-concentration metric (newly added output), the explicit five-gate chain + per-gate verdicts + all-GO enforcement, and the 3R daily-max-loss framing.
- eval-2 with_skill ran ALL FIVE gates from the orchestrator's inline thresholds with NO atom skills installed — validates the Phase B self-sufficiency fix.
- eval-1 with_skill: the new concentration line (top-3 = 84% of gross profit) tipped a positive-expectancy week to HOLD — the metric does real work.
- Cost: skill adds pass-rate for ~+10s/run and ~+4.4k tokens, mostly script execution + the structured gate walk.
