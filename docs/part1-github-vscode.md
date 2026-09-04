This step creates the local git repo that has been cloned from github repo
Thoubleshooting:

This step creates the local Git repo that has been cloned from the GitHub repo.

# Troubleshooting

This section documents common issues encountered while setting up and using the project repository.

## 1. Git command not found

### Problem

PowerShell returned:

```text
git : The term 'git' is not recognized
```

### Cause

Git was installed, but its installation directory was not included in the Windows `PATH`.

### Fix

Git was found at:

```text
C:\Users\Anatoly\AppData\Local\Programs\Git\cmd\git.exe
```

After adding this directory to the user `PATH`, Git worked normally.

Verify with:

```powershell
git --version
```

## 2. Git reports "dubious ownership"

### Problem

Git returned:

```text
fatal: detected dubious ownership in repository
```

### Cause

The repository folder was owned by a different Windows user account than the account currently running Git.

### Fix

The repository was explicitly marked as trusted:

```powershell
git config --global --add safe.directory C:/Users/Anatoly/Documents/GitHub/DO_project
```

Then verify:

```powershell
git status
```

## 3. Working in the wrong Git repository

### Problem

A branch was created in the old `devops` repository instead of the new `DO_project` repository.

### Cause

The terminal was opened in:

```text
C:\Users\Anatoly\Documents\GitHub\devops
```

instead of:

```text
C:\Users\Anatoly\Documents\GitHub\DO_project
```

### Fix

Change to the correct directory:

```powershell
cd C:\Users\Anatoly\Documents\GitHub\DO_project
```

Verify the active repository:

```powershell
git rev-parse --show-toplevel
```

Expected result:

```text
C:/Users/Anatoly/Documents/GitHub/DO_project
```

## 4. Repository accidentally nested inside another repository

### Problem

`DO_project` was initially created inside the existing `devops` repository.

Example:

```text
GitHub/
└── devops/
    └── DO_project/
```

Git therefore treated `DO_project` as part of the `devops` repository.

### Fix

The project repositories were separated:

```text
GitHub/
├── devops/
└── DO_project/
```

Each repository now has its own `.git` directory.

## 5. SSH authentication failed

### Problem

Running:

```powershell
ssh -T git@github.com
```

returned:

```text
Permission denied (publickey)
```

### Cause

GitHub could be reached, but no authorized SSH key was available.

### Fix

Check existing SSH files:

```powershell
ls ~/.ssh
```

Generate a key if necessary:

```powershell
ssh-keygen -t ed25519 -C "your-email@example.com"
```

Add the public key to GitHub under:

```text
Settings → SSH and GPG keys
```

Then verify:

```powershell
ssh -T git@github.com
```

## 6. Invalid Git branch name

### Problem

This command failed:

```powershell
git switch -c part1:github_repo-vscode
```

### Cause

Git branch names cannot contain `:`.

### Fix

Use `/`, `-`, or `_` instead:

```powershell
git switch -c part1/github_repo-vscode
```

## 7. PowerShell syntax mistakes

### Example 1

Incorrect:

```powershell
ls -Forse
```

Correct:

```powershell
ls -Force
```

### Example 2

Incorrect:

```powershell
git switch -c <part1/github_repo-vscode>
```

PowerShell interprets `<` and `>` as syntax characters.

Correct:

```powershell
git switch -c part1/github_repo-vscode
```

## Useful Diagnostic Commands

```powershell
git status
git branch -a
git remote -v
git rev-parse --show-toplevel
git --version
ssh -T git@github.com
where.exe git
ls -Force
```

These commands are useful for quickly checking the current repository, branch, remote configuration, Git installation, and SSH connectivity.