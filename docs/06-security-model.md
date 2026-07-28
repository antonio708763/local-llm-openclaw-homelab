# Security Model

Treat the model as an untrusted planner and OpenClaw as the privileged execution broker.

## Trust boundaries

```text
User
  |
  v
OpenClaw Gateway
  +-- token authentication
  +-- cautious execution policy
  +-- allowlist with ask-on-miss
  |
  +-- Command sandbox
  |     +-- unprivileged sandbox user
  |     +-- /workspace read/write
  |     +-- /forge-share read/write
  |     `-- no Ubuntu home or whole-drive mount
  |
  `-- Browser sandbox
        +-- dedicated Docker image and network
        +-- host-browser control disabled
        +-- no personal browser profile
        +-- no Forge_Shared bind
        `-- webpage content treated as untrusted
```

## Ubuntu host

- Read approved project repositories.
- Write only inside approved workspaces and deliberately selected exchange folders.
- Require approval for package installation, service changes, firewall changes, broad filesystem operations, and security-sensitive actions.
- Keep the OpenClaw Gateway loopback-only until authenticated LAN access is deliberately configured.
- Keep Ollama and SearXNG loopback-only unless a separate reviewed design requires otherwise.

## Command sandbox

- Run normal generated commands inside Docker.
- Use the unprivileged `sandbox` account.
- Mount `~/.openclaw/workspace` as `/workspace` read/write.
- Mount only `/mnt/Dual_Boot_Share/Forge_Shared` as `/forge-share:rw`.
- Do not mount the entire `Dual_Boot_Share` partition.
- Do not mount `/home/antonio` or unrelated host directories.
- Keep command execution under the cautious allowlist and ask-on-miss policy.
- Review every new external bind source before enabling it.

An external bind is an intentional hole through the sandbox wall. Keep the hole smaller than the data set it protects.

## Managed browser

- Use `openclaw-sandbox-browser:bookworm-slim` on the dedicated `openclaw-sandbox-browser` Docker network.
- Keep host-browser control disabled.
- Do not mount Chrome, Chromium, Firefox, password-manager, or credential directories.
- Keep browser binds explicitly empty unless a future reviewed use case requires otherwise.
- Do not expose `Forge_Shared` or the rest of `Dual_Boot_Share` to the browser.
- Do not use the managed browser for banking, personal email, password managers, sensitive cloud consoles, identity administration, or production infrastructure administration.
- Treat search results and webpage instructions as hostile input until independently verified.

## Shared-folder rules

Approved path:

```text
/mnt/Dual_Boot_Share/Forge_Shared -> /forge-share:rw
```

- Keep passwords, tokens, private keys, identity documents, and sensitive personal data out of `Forge_Shared`.
- Use the folder for deliberate file exchange, reviewed artifacts, and project inputs.
- Confirm that files written by Forge are expected before opening or executing them outside the sandbox.
- Remove the bind and disable external bind sources if the exchange folder is no longer required.

## Remote systems

- Start read-only.
- Require approval for commands.
- Use dedicated non-administrator accounts.
- Use explicit allowlists.
- Prefer encrypted private-network access over public port forwarding.
- Log actions and verify rollback before expanding permissions.

## Production homelab

- Inventory and status checks only at first.
- No automatic firewall, DNS, storage, Docker, Proxmox, identity, or backup changes.
- Require a separate approval before moving from observation to modification.
- Test automation on lab systems before production.

## Lab systems

- Approval-required changes.
- Snapshots before major work.
- Git-tracked configuration.
- Prefer APIs, SSH, Ansible, and scripts over GUI automation.
- Expand permissions only after repeated successful validation.

## Network exposure

- No public port forwarding for OpenClaw.
- Keep token authentication enabled.
- Restrict trusted-LAN access with host firewall rules.
- Confirm Guest and IoT VLANs cannot connect.
- Configure `gateway.trustedProxies` before placing the Control UI behind a reverse proxy.
- Use NetBird or another reviewed encrypted overlay for remote access.

## Secrets

Never commit API keys, OpenClaw tokens, NetBird setup keys, SSH private keys, Cloudflare tokens, SearXNG secret keys, authentication cookies, or infrastructure credentials.

Review local evidence bundles before committing selected text artifacts. Runtime identifiers and local paths may be acceptable documentation, but secret-bearing configuration files are not.
