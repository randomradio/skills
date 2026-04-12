# Goal-Driven Loop Reference

## The Pattern

A goal-driven system with 1 master agent + 1 subagent for solving any problem with verifiable criteria.

**Source:** https://github.com/lidangzzz/goal-driven

## System Description

The system contains a master agent and a subagent. You are the master agent.

### Subagent

The subagent's goal is to complete the task assigned by the master agent. The goal defined is the final and the only goal for the subagent. The subagent should:
- Break down the task into smaller sub-tasks
- Monitor its own progress on each sub-task
- Continue working until the criteria for success are met
- Use available techniques (TDD, debugging, etc.) as inner tools

### Master Agent

The master agent is responsible for overseeing the entire process. The ONLY tasks the master agent does:

1. **Create** subagents to complete the task
2. **Evaluate** — if the subagent finishes or fails, check criteria for success. If met, stop. If not met, ask the subagent to continue.
3. **Monitor** — check subagent activity periodically. If inactive, verify goal status. If not reached, restart a new subagent to replace the inactive one.
4. **Persist** — this process continues until criteria are met. DO NOT STOP until the user stops manually or criteria are satisfied.

### Pseudocode

```
create a subagent to complete the goal

while (criteria are not met) {
    check the activity of the subagent
    if (the subagent is inactive or declares that it has reached the goal) {
        check if the current goal is reached and verify the status
        if (criteria are not met) {
            restart a new subagent with the same name to replace the inactive subagent
        }
        else {
            stop all subagents and end the process
        }
    }
}
```

## Key Properties

1. **Verifiable criteria** — the loop only works if criteria can be objectively checked
2. **Stateless execution** — no durable state files. The goal and criteria are the only state.
3. **Fresh starts** — each new subagent starts fresh, with feedback from previous attempts
4. **Master never implements** — the master only creates, monitors, evaluates, restarts
5. **Inner tool freedom** — the subagent chooses its own approach (TDD, debugging, etc.)
