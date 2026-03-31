# Day 6 - Git Standards + Repo Hygiene

## Date
10 Mar 2026 (Tue)

---

## What We Did

Restructured the repo, added Git standards, and created a Makefile
with common commands.

---

## Folder Structure

---

## Files Added

| File | Purpose |
|------|---------|
| `.editorconfig` | Consistent formatting across editors |
| `.gitignore` | Ignore unwanted files from git |
| `Makefile` | One-command shortcuts for run, test, backup |
| `README.md` | Quick start guide for the project |

---

## Branch Naming Convention

| Type | Pattern | Example |
|------|---------|---------|
| New feature | `feature/<short-desc>` | `feature/add-login` |
| Bug fix | `bugfix/<short-desc>` | `bugfix/fix-timezone` |

---

## Commit Message Convention

| Prefix | Use for | Example |
|--------|---------|---------|
| `feat:` | New feature | `feat: add login page` |
| `fix:` | Bug fix | `fix: handle null user` |
| `chore:` | Maintenance | `chore: update dependencies` |

---

## Makefile Commands

| Command | What it does |
|---------|-------------|
| `make run` | Runs the PHP app |
| `make test` | Runs the tests |
| `make backup` | Creates a timestamped backup in /tmp/ |

---

## Issues Faced and Fixes

### 1. missing separator error in Makefile
- **Cause:** Spaces used instead of Tab key
- **Fix:** Use real Tab character before each command in Makefile

### 2. make run failed - python not found
- **Cause:** App uses PHP not Python
- **Fix:** Changed `python app/main.py` to `php app/site/index.php`

### 3. make backup failed - file changed as we read it
- **Cause:** tar was including the backup file it was creating
- **Fix:** Save backup to `/tmp/` folder outside the repo

---

## Git Commands Used

```bash
# Set identity
git config --global user.name "Your Name"
git config --global user.email "your@email.com"

# Create and push branch
git checkout -b feature/add-login
git add .
git commit -m "feat: add login page"
git push -u origin feature/add-login
```

---

## Verification

- [x] Repo pushed to GitHub
- [x] make run works
- [x] make test works  
- [x] make backup works
- [x] README has one-command run steps
- [x] Branch naming convention defined
- [x] Commit message convention defined
