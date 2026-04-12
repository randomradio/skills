---
name: rr:tdd
description: "Use when implementing any feature or bugfix, before writing implementation code. Enforces test-first red-green-refactor discipline."
---

# Test-Driven Development

Write the test first. Watch it fail. Write minimal code to pass.

## The Iron Law

```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

Write code before the test? Delete it. Start over. No exceptions.

## When to Use

**Always:** New features, bug fixes, refactoring, behavior changes.

**Exceptions (ask user):** Throwaway prototypes, generated code, configuration files.

## Red-Green-Refactor

### RED — Write Failing Test

Write one minimal test showing what should happen.

Requirements:
- One behavior per test
- Clear name describing the behavior
- Real code, not mocks (unless unavoidable)

### Verify RED — Watch It Fail (MANDATORY)

```bash
# Run the test
[project test command] path/to/test
```

Confirm:
- Test fails (not errors)
- Failure message is expected
- Fails because feature missing, not typos

Test passes? You're testing existing behavior. Fix test.
Test errors? Fix error, re-run until it fails correctly.

### GREEN — Minimal Code

Write the simplest code to pass the test. Nothing more.

Don't add features, refactor other code, or "improve" beyond the test.

### Verify GREEN — Watch It Pass (MANDATORY)

```bash
# Run the test
[project test command] path/to/test
```

Confirm:
- Test passes
- Other tests still pass
- Output pristine (no errors, warnings)

Test fails? Fix code, not test.
Other tests fail? Fix now.

### REFACTOR — Clean Up

After green only:
- Remove duplication
- Improve names
- Extract helpers

Keep tests green. Don't add behavior.

## Red Flags — STOP and Start Over

- Code before test
- Test passes immediately (you're testing existing behavior)
- Can't explain why test failed
- "Just this once" rationalization
- "I'll test after" thinking
- "Too simple to test"

**All of these mean: Delete code. Start over with TDD.**

## Debugging Integration

Bug found? Write failing test reproducing it. Follow TDD cycle. Test proves fix and prevents regression. Never fix bugs without a test.

## Verification Checklist

Before marking work complete:

- [ ] Every new function/method has a test
- [ ] Watched each test fail before implementing
- [ ] Each test failed for expected reason
- [ ] Wrote minimal code to pass each test
- [ ] All tests pass
- [ ] Tests use real code (mocks only if unavoidable)

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Too simple to test" | Simple code breaks. Test takes 30 seconds. |
| "I'll test after" | Tests passing immediately prove nothing. |
| "Need to explore first" | Fine. Throw away exploration, start with TDD. |
| "Test hard = design unclear" | Listen to test. Hard to test = hard to use. |
| "TDD will slow me down" | TDD faster than debugging. |
| "Manual test faster" | Manual doesn't prove edge cases. |
