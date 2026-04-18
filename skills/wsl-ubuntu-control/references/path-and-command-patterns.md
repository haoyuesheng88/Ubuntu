# Path And Command Patterns

Use this reference when the user mixes Windows and Linux paths or when the command needs a safe verification step.

## Windows To WSL Path Examples

```text
C:\Users\QF100\Documents\New project
/mnt/c/Users/QF100/Documents/New project
```

```text
D:\work\ubuntu-demo
/mnt/d/work/ubuntu-demo
```

## Common Command Patterns

Check basic Ubuntu identity:

```bash
pwd && whoami && uname -a
```

List a home directory:

```bash
ls -la /home/shy3
```

Create a directory and file manually:

```bash
mkdir -p /tmp/demo && printf 'hello\n' > /tmp/demo/hello.txt
```

Verify a file exists and show content:

```bash
ls -l /tmp/demo/hello.txt && cat /tmp/demo/hello.txt
```

## When To Prefer Each Script

Use `invoke-wsl-command.ps1` when:

- the task is mainly command execution
- the user asked to inspect, install, run, or list something
- shell operators such as `&&` are useful

Use `write-file-in-ubuntu.ps1` when:

- the user gave exact text that must be written
- quoting would be awkward
- the content may contain spaces, punctuation, or line breaks

## Portability Notes

- Assume WSL2 is available, but verify with `wsl.exe -l -v` before claiming success.
- Default distro names vary. Common names include `Ubuntu`, `Ubuntu-24.04`, and custom distro names.
- Do not hardcode usernames in the skill body. Use the user-provided path or discover it with `whoami` and `echo $HOME`.
