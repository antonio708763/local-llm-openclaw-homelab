# OpenClaw Local Installation and Onboarding

## Goal

Install OpenClaw on Ubuntu, connect it to the local Ollama service, keep all access local during the first validation, and create a clean checkpoint that can survive a normal shutdown.

## Installation

OpenClaw was installed without immediately launching onboarding:

```bash
curl -fsSL https://openclaw.ai/install.sh | bash -s -- --no-onboard
```

The installer reported:

```text
OpenClaw version: 2026.7.1-2
Node.js version:  24.18.0
npm version:      11.16.0
Install method:   npm user-global prefix
OpenClaw path:    /home/antonio/.npm-global/bin/openclaw
```

The installer added `/home/antonio/.npm-global/bin` to `~/.bashrc`.

## Initial PATH issue

Immediately after installation, the current shell returned:

```text
openclaw: command not found
```

The installation itself was successful. The current terminal simply had not reloaded the updated PATH.

Resolution:

```bash
source ~/.bashrc
hash -r
openclaw --version
command -v openclaw
```

Validated result:

```text
OpenClaw 2026.7.1-2
/home/antonio/.npm-global/bin/openclaw
```

## Onboarding

Onboarding and Gateway service installation were started with:

```bash
openclaw onboard --install-daemon
```

Selections:

```text
Security disclaimer: accepted
Setup mode:          QuickStart
Gateway port:        18789
Gateway bind:        Loopback, 127.0.0.1
Gateway auth:        Token
Tailscale exposure:  Off
Provider:             Ollama
Ollama mode:          Local only
Ollama base URL:      http://127.0.0.1:11434
Default model:        ollama/qwen3-coder:30b
Messaging channels:  Skipped
Web search:           Skipped
```

The `/v1` suffix was intentionally not added. OpenClaw is connected to Ollama's native local API.

## Files and directories created

```text
Configuration:       ~/.openclaw/openclaw.json
Configuration backup: ~/.openclaw/openclaw.json.bak
Workspace:           ~/.openclaw/workspace
Sessions:            ~/.openclaw/agents/main/sessions
Gateway service:     ~/.config/systemd/user/openclaw-gateway.service
```

The primary OpenClaw workspace remains on Ubuntu's native filesystem. Access to `/mnt/Dual_Boot_Share` will be granted deliberately later rather than making the shared NTFS partition the unrestricted primary workspace.

## TUI validation

The onboarding process opened the TUI at:

```text
ws://127.0.0.1:18789
```

The TUI showed:

```text
Agent:   main
Session: main
Model:   ollama/qwen3-coder:30b
State:   connected | idle
```

The model produced the expected first-run identity/bootstrap message.

The footer displayed `0/262k` tokens. This has not yet been treated as the real Ollama allocation because `ollama ps` previously showed a 32,768-token context. The difference must be investigated before relying on very large contexts.

## Gateway health validation

After leaving the TUI with `Ctrl+C`, the following checkpoint commands were run:

```bash
openclaw gateway status --require-rpc
systemctl is-active ollama
```

Observed Gateway state:

```text
Service manager: systemd user
Service state:   enabled
Runtime:         running, active
Gateway bind:    loopback, 127.0.0.1
Gateway port:    18789
RPC read probe:  ok
Listening:       127.0.0.1:18789 and [::1]:18789
Ollama service:  active
```

The status also reported `connected-no-operator-scope`. This is recorded as observed output and will be interpreted during the permissions review rather than assumed to be an error.

## Current security boundary

At this checkpoint:

- OpenClaw is reachable only from the local Ubuntu computer.
- The Gateway uses token authentication.
- Tailscale exposure is off.
- NetBird exposure has not been configured.
- LAN binding has not been enabled.
- No messaging channels are connected.
- Web search is not configured.
- Ollama remains local at `127.0.0.1:11434`.
- Remote nodes and broad filesystem permissions are not configured.

This is the intended safe stopping point.

## Clean stop procedure

Leave the TUI:

```text
Ctrl+C
```

Verify the services:

```bash
openclaw gateway status --require-rpc
systemctl is-active ollama
```

Shut down Ubuntu normally:

```bash
sudo shutdown now
```

## Resume after powering the computer back on

Run:

```bash
systemctl is-active ollama
openclaw gateway status --require-rpc
openclaw tui
```

If the Gateway did not start automatically:

```bash
openclaw gateway start
openclaw tui
```

The TUI should reconnect to agent `main` and session `main`.

## Next tasks

1. Verify the shared NTFS mount, Ollama, and Gateway after a reboot.
2. Complete the identity/bootstrap conversation.
3. Inspect the current tool profile and permission model.
4. Keep command execution approval-required.
5. Decide which paths OpenClaw may read and write.
6. Run one harmless local tool command.
7. Confirm the true model context available through OpenClaw.
8. Configure trusted LAN access only after the local security boundary is understood.
