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

## Docker and sandbox checkpoint

- `docker-sandbox-checkpoint-1.webp`
- `docker-sandbox-checkpoint-2.webp`

These two images preserve the Docker installation/validation and OpenClaw sandbox-configuration checkpoint. They use neutral numbering because they were uploaded from prepared binary blobs and have not yet been relabeled after a visual review in GitHub.

See `docker-sandbox-checkpoint-notes.md` for the checkpoint description.

## Image format

Screenshots are stored as WebP images. WebP reduces repository size while preserving terminal text and remaining directly viewable in GitHub and modern browsers.
