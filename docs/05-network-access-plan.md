# Network Access Plan

## Requirements

- Trusted LAN access to OpenClaw.
- Encrypted remote access when away from home.
- Ollama remains private behind OpenClaw.
- SearXNG remains private behind OpenClaw.
- No direct public port-forward to the model runtime or Gateway.
- Gateway token authentication remains enabled.

## Selected trusted-LAN design

The first trusted Linux client uses an SSH local-forward tunnel instead of changing the OpenClaw Gateway bind.

```text
Trusted Linux client
  browser -> http://127.0.0.1:18789
                  |
                  | encrypted SSH tunnel to TCP 22
                  v
Forge host 192.168.110.187
                  |
                  v
OpenClaw Gateway 127.0.0.1:18789
                  |
                  +-- Ollama 127.0.0.1:11434
                  `-- SearXNG 127.0.0.1:8888
```

This keeps the Gateway, Ollama, and SearXNG loopback-only. The LAN-facing control point is OpenSSH, protected by a dedicated client key. The Gateway token remains a second authentication layer.

The tested client is an Ubuntu-based Alienware laptop. Its own older OpenClaw Gateway was disabled because it occupied local port `18789`. A persistent systemd user service now maintains the tunnel and reconnects after reboot.

See `17-trusted-linux-client-ssh-tunnel.md` for the complete build and validation record.

## Why this was selected

- No direct OpenClaw LAN bind is required.
- No reverse proxy is required for the first client.
- The Gateway continues to reject ordinary LAN connections because it still listens only on loopback.
- Access can be granted or revoked per client SSH key.
- Encryption and host authentication are provided by SSH.
- Existing token authentication remains intact.
- The design is reversible and does not require router port forwarding.

## Remaining trusted-LAN work

- Disable SSH password authentication after key recovery access is confirmed.
- Consider a dedicated restricted tunnel account instead of the administrator account.
- Restrict TCP port 22 with UFW and OPNsense to approved trusted clients or the trusted VLAN.
- Confirm Guest and IoT VLANs cannot reach the Forge host SSH service.
- Test automatic tunnel recovery after Wi-Fi interruption and Forge-host restart.

## Encrypted remote access

Audit and reuse the existing self-hosted NetBird deployment if it is healthy. Verify server versions, authentication, relay operation, peer-to-peer connectivity, groups, policies, DNS, and routing peers before relying on it.

A future remote client may use the same SSH-forward pattern over NetBird, keeping the OpenClaw Gateway loopback-only.

## Alternatives

| Option | Advantage | Drawback |
|---|---|---|
| SSH local forwarding | Simple, encrypted, per-key access, Gateway remains loopback-only | Requires SSH lifecycle and key management |
| Direct trusted-LAN Gateway bind | Fewer client steps | Exposes the Gateway socket to the LAN and requires stricter firewall rules |
| Local reverse proxy | Central TLS and policy point | Adds another service and trusted-proxy configuration |
| Self-hosted NetBird | Dashboard, policies, WireGuard, self-hosting | More components to maintain |
| Tailscale cloud | Easy and reliable | Hosted control plane |
| Headscale | Self-hosted Tailscale control plane | More manual administration |
| Raw WireGuard | Minimal and fully controlled | Manual peers and routes |

## Exposure policy

- Keep OpenClaw on `127.0.0.1:18789` while SSH forwarding meets the access requirement.
- Keep Ollama on `127.0.0.1:11434`.
- Keep SearXNG on `127.0.0.1:8888`.
- Use OpenClaw as the authenticated front door.
- Allow SSH only from trusted LAN systems and approved encrypted-overlay peers.
- Never publish OpenClaw, Ollama, or SearXNG directly through an Internet-facing router port-forward.