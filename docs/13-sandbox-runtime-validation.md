# Sandbox Runtime Validation

## Purpose

This checkpoint proves that Forge's normal command execution runs inside the Docker sandbox rather than directly on Ubuntu, while preserving controlled workspace writes and outbound Internet access.

## Execution policy

Normal execution was changed to the sandbox while retaining the cautious policy:

```text
host=sandbox
security=allowlist
ask=on-miss
askFallback=deny
```

The Gateway was restarted and `openclaw exec-policy show` confirmed the effective policy.

## First command test

Forge was asked to run:

```bash
id
pwd
cat /etc/os-release
ls -la /workspace
test -e /home/antonio \
  && echo "FAIL: host home is visible" \
  || echo "PASS: host home is not visible"
```

Observed results:

```text
uid=1000(sandbox) gid=1000(sandbox) groups=1000(sandbox)
working directory: /workspace
operating system: Debian GNU/Linux 12 (bookworm)
/home/antonio visible: no
```

The workspace contained the expected OpenClaw identity and operating files, including `AGENTS.md`, `IDENTITY.md`, `SOUL.md`, `TOOLS.md`, and `USER.md`.

## Automatic runtime creation

Before the first tool request, `openclaw sandbox list` reported zero runtimes. After the request, it reported one running runtime:

```text
Name:    openclaw-sbx-agent-main-...
Status:  running
Image:   openclaw-sandbox:bookworm-slim
Backend: docker
Session: agent:main
```

`docker ps` independently confirmed the same running container.

## Workspace persistence test

Forge created:

```text
/workspace/sandbox-test.txt
```

with the contents:

```text
Forge sandbox write test successful
```

Inside the container, the file appeared as owned by `sandbox:sandbox`. On Ubuntu, the same file appeared at:

```text
~/.openclaw/workspace/sandbox-test.txt
```

and was owned by `antonio:antonio`.

This ownership translation is expected because the sandbox user and Ubuntu user both use numeric UID and GID `1000` across the bind mount.

## Network test

Forge ran:

```bash
getent hosts example.com
curl -fsSI https://example.com | head -n 5
```

Results:

- DNS resolution succeeded.
- IPv6 records were returned for `example.com`.
- HTTPS completed successfully.
- The response returned `HTTP/2 200`.

## Validated security boundary

Confirmed:

- Normal commands execute inside Docker.
- The container uses an unprivileged user.
- The container sees the OpenClaw workspace at `/workspace`.
- Workspace writes persist to the intended Ubuntu workspace.
- `/home/antonio` is not mounted or visible.
- `Dual_Boot_Share` is not mounted.
- Outbound DNS and HTTPS work through Docker bridge networking.
- No container port is published to the LAN or Internet.

## Approval behavior note

No approval dialog appeared for these sandbox-contained commands. The observed host policy remains `allowlist` with `ask-on-miss`; approval behavior for commands targeting the Gateway or future nodes should be tested separately before enabling host or node execution.

## Next phase

1. Deploy SearXNG as a self-hosted search service.
2. Enable and test its JSON search API.
3. Configure OpenClaw `web_search` to use SearXNG.
4. Configure the managed browser separately because the current sandbox tool policy denies browser control by default.
5. Rerun `openclaw security audit --deep` after those changes.
