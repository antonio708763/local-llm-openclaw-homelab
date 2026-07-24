# Security Model

Treat the model as an untrusted planner and OpenClaw as the privileged execution broker.

## Initial permissions

### Ubuntu host

- Read approved project repositories.
- Write only inside approved workspaces.
- Require approval for package installation, service changes, and broad filesystem operations.

### Remote systems

- Start read-only.
- Require approval for commands.
- Use dedicated non-administrator accounts.
- Use explicit allowlists.

### Production homelab

- Inventory and status checks only at first.
- No automatic firewall, DNS, storage, Docker, or Proxmox changes.

### Lab systems

- Approval-required changes.
- Snapshots before major work.
- Git-tracked configuration.
- Prefer APIs, SSH, Ansible, and scripts over GUI automation.

## Secrets

Never commit API keys, OpenClaw tokens, NetBird setup keys, SSH private keys, Cloudflare tokens, or infrastructure credentials.
