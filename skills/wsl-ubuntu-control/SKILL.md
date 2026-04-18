---
name: wsl-ubuntu-control
description: Control a local Ubuntu or other WSL distro from Windows through `wsl.exe`. Use when Codex needs to run Linux commands in a local Ubuntu terminal, inspect or modify files under `/home` or `/mnt/c`, create text files inside Ubuntu, translate Windows paths into WSL paths, or verify command output without using SSH or a remote host.
---

# WSL Ubuntu Control

Use this skill to operate a local Ubuntu environment on Windows through WSL.

Prefer the bundled PowerShell scripts over ad hoc quoting when the task involves path translation, file creation, or repeated command execution.

## Choose The Workflow

1. Run a Linux command in Ubuntu:
Run [scripts/invoke-wsl-command.ps1](./scripts/invoke-wsl-command.ps1).

2. Create or overwrite a text file in Ubuntu with exact content:
Run [scripts/write-file-in-ubuntu.ps1](./scripts/write-file-in-ubuntu.ps1).

3. Confirm the skill works on a new machine:
Run [scripts/smoke-test.ps1](./scripts/smoke-test.ps1).

## Working Rules

- Treat `wsl.exe` as the control surface. Do not claim to attach to a GUI terminal tab when the work is really being done through WSL commands from Windows.
- Prefer `-WindowsWorkingDirectory` when the task starts from a Windows folder such as `C:\Users\name\Documents\Project`. The script converts it to `/mnt/c/...` automatically.
- Prefer `-LinuxWorkingDirectory` when the user already gave a Linux path such as `/home/user/project`.
- After any file write, verify with a second command such as `ls -l`, `cat`, `sed -n`, or `test -f`.
- When the user asks for a file with specific text, use the file-writing script instead of building a fragile inline shell redirection command.

## PowerShell Usage

Run a command in the current Windows-backed project directory:

```powershell
& '.\skills\wsl-ubuntu-control\scripts\invoke-wsl-command.ps1' `
  -Distro Ubuntu `
  -WindowsWorkingDirectory 'C:\Users\name\Documents\Project' `
  -Command "ls -la"
```

Run a command directly in a Linux directory:

```powershell
& '.\skills\wsl-ubuntu-control\scripts\invoke-wsl-command.ps1' `
  -Distro Ubuntu `
  -LinuxWorkingDirectory '/home/name' `
  -Command "pwd && whoami"
```

Write a file with exact text:

```powershell
& '.\skills\wsl-ubuntu-control\scripts\write-file-in-ubuntu.ps1' `
  -Distro Ubuntu `
  -LinuxPath '/tmp/example.txt' `
  -Text "abc`n"
```

## Command Strategy

- Use ordinary shell commands for exploration: `pwd`, `whoami`, `ls -la`, `find`, `cat`, `sed -n`.
- Use the write script for precise text creation because it avoids quoting and encoding mistakes.
- Prefer concise verification output. After success, report the path, key output, and whether the content matched the request.
- If the distro name is not `Ubuntu`, discover it first with `wsl.exe -l -v` and rerun with the correct `-Distro`.

For path translation examples and common patterns, see [references/path-and-command-patterns.md](./references/path-and-command-patterns.md).

## Validation

Before reporting success:

- confirm the target distro exists
- confirm the command exited successfully
- confirm the file or directory state actually changed
- confirm the resulting text matches the user request when the task writes content

## Deliverable

Report the distro used, the important command result, and the final file path or command output.
