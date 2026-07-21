---
name: update-readme-push
description: Update a daily learning project's README with new content and push to GitHub. Use after adding a new day's work (SQL files, notes, etc.) to a revision or learning repo.
---

# Update README & Push to GitHub

Use this skill when the user has added new content (e.g., a new day's SQL file) to a daily learning/revision project and wants the README updated and changes pushed.

## When to Use

- User says "update README and push", "do the next step", "push to GitHub", or similar
- The project follows a daily/sequential learning structure (Day 1, Day 2, ...)
- New files have been added that need to be reflected in the README

## Procedure

### Step 1: Discover New Content

1. Read the project directory to list all files
2. Read the existing README.md to understand current structure
3. Identify new files added since last update (compare README content vs actual files)
4. Read new SQL/notebook files to extract topics covered

### Step 2: Update README.md

Update two sections of the README:

**Progress table** — add a new row:
```markdown
| Day | File | Topics |
|-----|------|--------|
| N | `SQL_DayN.sql` | Topic 1, Topic 2, ... |
```

**Topics section** — add a new subsection:
```markdown
### Day N — Topic Title
- Bullet point 1
- Bullet point 2
- Bullet point 3
```

Extract actual topics by reading the SQL file contents — list the key concepts demonstrated (e.g., JOINs, CTEs, window functions, aggregate functions).

### Step 3: Update Memory (if applicable)

If the project has a `.mimocode/MEMORY.md` or memory folder, update the progress section with the new day's entry.

### Step 4: Git Commit & Push

```bash
git status
git add README.md <new_files>
git commit -m "Day N: Add <topic description>"
git push
```

Use descriptive commit messages that summarize what was added (e.g., "Day 3: Add Date/Time functions, NULL handling, CASE statement").

## Stopping Condition

- README updated with new day's entry in both progress table and topics section
- Memory file updated (if present)
- Changes committed and pushed to GitHub

## Example

User says: "completed day 6 of sql, can you update readme and push"

Agent:
1. Lists project files, reads README.md
2. Reads SQL_Day6.sql to extract topics (Recursive CTEs, Views)
3. Adds row to progress table: `| 6 | SQL_Day6.sql | Recursive CTEs, Views |`
4. Adds topics subsection with bullet points
5. Commits: `git add README.md SQL_Day6.sql && git commit -m "Day 6: Add Recursive CTEs and Views" && git push`
