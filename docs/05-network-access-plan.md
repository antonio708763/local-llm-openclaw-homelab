# Network Access Plan

## Requirements

- Trusted LAN access to OpenClaw.
- Encrypted remote access when away from home.
- Ollama remains private behind OpenClaw.
- No direct public port-forward to the model runtime.

## Preferred flow

```text
LAN client ----------------------\
                                  > OpenClaw Gateway -> Ollama -> Qwen
Remote NetBird client -----------/
```

## Current leading option

Audit and reuse the existing self-hosted NetBird deployment if it is healthy. Verify server versions, authentication, relay operation, peer-to-peer connectivity, groups, policies, DNS, and routing peers before relying on it.

## Alternatives

| Option | Advantage | Drawback |
|---|---|---|
| Self-hosted NetBird | Dashboard, policies, WireGuard, self-hosting | More components to maintain |
| Tailscale cloud | Easy and reliable | Hosted control plane |
| Headscale | Self-hosted Tailscale control plane | More manual administration |
| Raw WireGuard | Minimal and fully controlled | Manual peers and routes |

## Exposure policy

- Keep Ollama on `127.0.0.1:11434` initially.
- Use OpenClaw as the authenticated front door.
- Allow only trusted LAN systems and approved remote peers.
