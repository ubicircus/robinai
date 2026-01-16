# Development Log Guidelines

This directory contains the daily development logs for the **RobinAI** project. These logs serve as a knowledge base, a debugging aid, and a handover mechanism between sessions or agents.

## File Naming Convention

- **Format:** `YYYY-MM-DD.md` (e.g., `2026-01-16.md`)
- **Location:** `_log/` root.

## Log Structure Template

Copy the following template for each new log entry:

```markdown
# Log [YYYY-MM-DD]

## 1. Session Objective

<!-- What was the primary goal or goals of this session? -->

## 2. Key Changes & Implementation

<!-- High-level summary of code changes. Group by functionality. -->

### [Feature Name / Component]

- **Added/Modified:** [Details]
- **Technical Decision:** [Why did we choose this approach?]

## 3. Challenges & Debugging

<!-- CRITICAL SECTION: Document any errors, bugs, or "stuck" moments. -->

### [Issue Title: e.g., "State Synchronization Error"]

- **Symptoms:** [Error message, visible behavior]
- **Hypothesis:** [What did we think was wrong?]
- **Solution:** [How did we fix it?]
- **Takeaway:** [Anti-patterns to avoid or key learnings]

## 4. Current Status

<!-- What is the state of the app right now? -->

- [x] [Working Feature]
- [ ] [Broken/Incomplete Feature]

## 5. Next Steps

<!-- Specific action items for the next developer/agent. -->

- [ ] [Action Item 1]
- [ ] [Action Item 2]
```

## Best Practices

1.  **Be Explicit about Errors:** Don't just say "Fixed the build." Say "Fixed 'Version mismatch in win32' by removing dependency X."
2.  **Document "Why":** Code explains _how_, logs explain _why_.
3.  **Update "Next Steps":** Always leave a clean starting point for the next session.
