# Changelog

## 2026-07-28

### Added

- `docs/15-managed-browser-and-security-audit.md`.
- Isolated OpenClaw managed-browser image `openclaw-sandbox-browser:bookworm-slim`.
- Dedicated Docker network `openclaw-sandbox-browser` for browser automation.
- Browser snapshot and screenshot validation.
- Local managed-browser evidence bundle under `~/.openclaw/workspace/checkpoints/2026-07-28-managed-browser/`.

### Completed

- Identified that the OpenClaw npm package did not expose a usable `gitHead` value for browser-image source retrieval.
- Matched OpenClaw `2026.7.1-2` to the `v2026.7.1` Git tag.
- Cloned the matching OpenClaw source and built the official sandbox-browser image.
- Enabled the isolated browser sandbox and automatic startup.
- Configured the browser image and dedicated Docker network.
- Disabled host-browser control.
- Enabled noVNC support while keeping browser automation isolated.
- Added `browser` to the global and sandbox tool policy gates.
- Created the first browser container automatically through a Forge browser request.
- Opened `https://example.com` and validated the final URL, title, and main heading.
- Generated a browser snapshot and screenshot.
- Verified screenshot files under `~/.openclaw/media/browser` and `~/.openclaw/media/outbound`.
- Inspected browser mounts and confirmed that no personal Chrome, Chromium, Firefox, or credential directories were exposed.
- Confirmed the browser container uses `openclaw-sandbox-browser:bookworm-slim` and the `openclaw-sandbox-browser` network.
- Pinned SearXNG to `@openclaw/searxng-plugin@2026.7.1`.
- Reran `openclaw security audit --deep`.
- Reduced the audit from one critical and two warnings to one critical and one warning.
- Accepted the small-model-with-web-tools finding as residual risk under the current single-user, sandboxed, loopback-only design.
- Determined that the trusted-proxies warning requires no change while the Gateway remains loopback-only and no reverse proxy is in use.
- Created browser configuration, image, runtime, policy, plugin, and audit evidence files locally.

### Pending

- The attempted Forge memory update did not complete.
- `MEMORY.md` still identifies managed-browser configuration as the next task.
- `memory/2026-07-28.md` does not yet exist.
- The local evidence bundle must be reviewed before selected artifacts are committed publicly.

### Current checkpoint

The isolated managed-browser and security-audit phase is complete. The next functional phase is controlled access to a dedicated `Dual_Boot_Share` folder, after repairing the pending durable-memory checkpoint.

## 2026-07-26

### Added

- `docs/13-sandbox-runtime-validation.md`.
- `docs/14-searxng-compaction-and-memory.md`.
- Self-hosted SearXNG container bound to `127.0.0.1:8888`.
- Persistent SearXNG configuration at `~/searxng/settings.yml` with HTML and JSON output enabled.
- OpenClaw SearXNG plugin and local `web_search` integration.
- Durable `MEMORY.md` and dated memory-note workflow.
- Current project checkpoint in `MEMORY.md`.

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
- Confirmed outbound DNS resolution and HTTPS access from the sandbox.
- Installed the OpenClaw SearXNG plugin.
- Deployed SearXNG in Docker with loopback-only port publishing.
- Resolved the initial JSON search `403` by enabling `search.formats: [html, json]`.
- Added `web_search` and `web_fetch` to the sandbox tool allowlist.
- Confirmed OpenClaw can search through the self-hosted SearXNG provider in a fresh session.
- Tuned compaction for the 32,768-token context using an 8,192-token reserve and 6,000 recent tokens.
- Inspected the detailed context breakdown and recorded approximately 8,929 tokens of startup context.
- Created and verified `MEMORY.md` and `memory/2026-07-26.md` from Ubuntu.
- Confirmed a new session recalled the durable homelab goals, hardware, model, and safety rules.
- Added the managed-browser task to the durable current-project checkpoint.
- Confirmed Docker, Ollama, the OpenClaw Gateway, and SearXNG were healthy at the stopping point.

### Current checkpoint

The self-hosted search, compaction, and durable-memory milestone is complete. The next task is to configure and test an isolated OpenClaw managed browser that remains separate from the personal browser profile.

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
