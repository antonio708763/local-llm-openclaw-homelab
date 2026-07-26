# Security Hardening and Docker Sandbox

This document preserves the detailed hardening decisions made before the first sandbox runtime test.

## Completed changes

- Forge identity created with a cautious, documentation-first operating style.
- Execution policy changed from `security=full, ask=off` to `security=allowlist, ask=on-miss` with deny fallback.
- `openclaw doctor` and `openclaw security audit --deep` reviewed.
- Oversized automatic context changes declined.
- Qwen `contextWindow` and Ollama `num_ctx` aligned at `32768`.
- Unused OpenAI-backed memory search disabled.
- Insecure Control UI authentication disabled.
- Temporary web/browser provider deny removed so controlled Internet tooling can be configured later.
- Docker Engine and Compose installed and validated.
- Custom `openclaw-sandbox:bookworm-slim` image built.
- OpenClaw configured for Docker sandboxing with mode `all`, agent scope, read/write workspace access, and bridge networking.

## Important boundaries

The Gateway and Ollama remain loopback-only. The sandbox currently receives only the OpenClaw workspace at `/workspace`; `Dual_Boot_Share` and unrelated host paths are not mounted. Browser control remains denied by the default sandbox tool policy and requires separate configuration.

## Current checkpoint

`openclaw sandbox list` reports zero runtimes because Forge has not made its first tool request. OpenClaw is expected to create the runtime lazily during the next harmless tool test.

See `docs/12-docker-and-sandbox.md` for commands, validation output, and the next checklist.
