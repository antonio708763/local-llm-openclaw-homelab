# Changelog

## 2026-07-26

### Completed

- Changed normal OpenClaw command execution from `host=gateway` to `host=sandbox`.
- Preserved the cautious policy with `security=allowlist`, `ask=on-miss`, and deny fallback.
- Ran Forge's first harmless command set inside the Docker sandbox.
- Confirmed OpenClaw automatically created and started an `openclaw-sbx-agent-main-...` runtime.
- Confirmed the runtime uses `openclaw-sandbox:bookworm-slim`.
- Confirmed commands run as the unprivileged `sandbox` user with UID and GID `1000`.
- Confirmed the working directory is `/workspace` and the container OS is Debian GNU/Linux 12.
- Confirmed `/home/antonio` is not visible from inside the sandbox.
- Created `/workspace/sandbox-test.txt` from Forge.
- Confirmed the file appeared on Ubuntu at `~/.openclaw/workspace/sandbox-test.txt`.
- Confirmed outbound DNS resolution from the sandbox.
- Confirmed outbound HTTPS access with an HTTP 200 response from `https://example.com`.

### Added

- `docs/13-sandbox-runtime-validation.md`.
- Screenshot evidence for the sandbox execution policy, first runtime test, running container, workspace persistence, and Internet connectivity.

### Current checkpoint

The Docker sandbox is now validated for command execution, host isolation, workspace persistence, DNS, and HTTPS. The next phase is self-hosted web search using SearXNG, followed by separate managed-browser configuration.

## 2026-07-25

### Added

- Docker Engine installation from Docker's official Ubuntu repository.
- Docker Compose plugin.
- Reusable `docker/openclaw-sandbox/Dockerfile`.
- `docs/12-docker-and-sandbox.md`.
- Screenshot evidence for Docker installation, reboot validation, sandbox image creation, sandbox configuration, policy inspection, and the pre-runtime checkpoint.

### Completed

- Confirmed `Dual_Boot_Share` mounts automatically after reboot.
- Confirmed Docker, Ollama, and the OpenClaw Gateway start correctly after reboot.
- Created the Forge identity and operating characteristics.
- Applied OpenClaw's cautious execution policy: `security=allowlist`, `ask=on-miss`.
- Disabled unavailable OpenAI-backed memory search.
- Disabled insecure Control UI authentication.
- Removed the temporary provider-specific web/browser deny rule.
- Corrected OpenClaw's Qwen context advertisement and Ollama `num_ctx` to `32768`.
- Installed Docker Engine `29.6.2` and Docker Compose `v5.3.1`.
- Successfully ran Docker's `hello-world` test.
- Added the Ubuntu administrator account to the Docker group and verified non-root Docker access after reboot.
- Built `openclaw-sandbox:bookworm-slim`.
- Configured OpenClaw sandbox mode `all`, Docker backend, agent scope, read/write workspace access, and bridge networking.
- Confirmed `openclaw sandbox explain` reports a sandboxed runtime with `/workspace` mapped to `~/.openclaw/workspace`.

## 2026-07-24

### Added

- Initial repository structure.
- Hardware and dual-boot architecture documentation.
- Windows-to-Ubuntu shared-partition build log.
- Backup and recovery notes.
- Network and security plans for OpenClaw.
- Read-only Windows and Ubuntu validation scripts.
- Screenshot evidence for storage, Ollama installation, model download, model response, and GPU validation.
- Detailed Ollama and `qwen3-coder:30b` validation record.
- OpenClaw local installation and onboarding documentation.
- Shutdown and restart commands for safely resuming the project.

### Completed

- Verified Windows data integrity after the partition resize.
- Configured `Dual_Boot_Share` at `/mnt/Dual_Boot_Share` using UUID `48003BD2003BC62A`.
- Confirmed NTFS read/write access from Ubuntu using the `ntfs3` driver.
- Verified NVIDIA driver and CUDA access.
- Installed Ollama `0.32.3` as an enabled systemd service.
- Downloaded `qwen3-coder:30b`.
- Confirmed `100% GPU` model residency on the RTX 4090.
- Validated a 32,768-token Ollama context allocation with approximately 21.7 GiB of VRAM in use.
- Installed OpenClaw `2026.7.1-2` and Node.js `24.18.0`.
- Connected OpenClaw to local Ollama.
- Installed and validated the local Gateway and TUI.
