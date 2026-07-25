# Screenshots

Screenshots provide evidence for major milestones and preserve troubleshooting context.

## Storage and model setup

- `dual-boot-share-mounted.webp` — Ubuntu Files showing the resized shared NTFS partition.
- `permanent-ntfs-mount-test.webp` — `mount -a`, `findmnt`, and the successful Ubuntu write test.
- `ollama-installation.webp` — Ollama installation, version, and active systemd service.
- `qwen3-coder-pull-complete.webp` — Completed `qwen3-coder:30b` download.
- `qwen3-coder-gpu-validation.webp` — `ollama ps` and `nvidia-smi` showing 100% GPU residency.
- `qwen3-coder-first-response.webp` — First coding response from the local model.

## OpenClaw local setup

- `openclaw-installation.webp` — OpenClaw and Node.js installation output.
- `openclaw-ollama-onboarding.webp` — Local Ollama URL, selected model, and onboarding progress.
- `openclaw-tui-connected.webp` — TUI connected to the main agent and main session.
- `openclaw-gateway-status.webp` — Enabled Gateway service, active runtime, successful RPC probe, loopback listener, and active Ollama service.

## Image format

Screenshots are stored as WebP images. WebP reduces repository size while remaining directly viewable in GitHub and modern browsers.

## Naming convention

```text
YYYY-MM-DD-description.webp
```

Existing names are kept concise because the current evidence was captured during the same build sessions.
