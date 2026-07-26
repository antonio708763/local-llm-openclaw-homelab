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

## Docker and sandbox

- `docker-install-verified.webp` — Successful `hello-world` test, Docker Engine and Compose versions, and active service.
- `post-reboot-services-healthy.webp` — Docker, Ollama, and OpenClaw Gateway health after reboot.
- `sandbox-image-build.webp` — Custom Debian sandbox image build and image-size verification.
- `sandbox-config-applied.webp` — OpenClaw sandbox settings applied, configuration validated, and Gateway restarted.
- `sandbox-policy-explained.webp` — Effective sandbox runtime, mounts, backend, network, and tool policy.
- `sandbox-list-empty.webp` — Expected zero-runtime checkpoint before Forge's first tool execution.

## Image format

Screenshots are stored as lossless WebP images. WebP reduces repository size while preserving terminal text and remaining directly viewable in GitHub and modern browsers.

## Naming convention

```text
YYYY-MM-DD-description.webp
```

Existing names remain concise because the evidence is grouped by documented build phase.
