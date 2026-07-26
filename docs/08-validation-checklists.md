# Validation Checklists

## Windows post-resize

- [x] Windows boots normally
- [x] `chkdsk C: /scan` reports no problems
- [x] Important files and applications remain accessible
- [x] Archive drives are visible
- [x] `Dual_Boot_Share` appears as `H:`
- [x] Files can be created and read on `H:`

## Ubuntu storage

- [x] Ubuntu boots normally
- [x] `Dual_Boot_Share` appears in Files
- [x] UUID recorded as `48003BD2003BC62A`
- [x] Mounted at `/mnt/Dual_Boot_Share`
- [x] NTFS read/write access confirmed
- [x] Automatic mount confirmed after reboot
- [ ] Confirm cross-OS file compatibility with files created from both operating systems

## Ollama and model

- [x] NVIDIA driver working
- [x] CUDA access verified
- [x] RTX 4090 visible
- [x] Ollama installed, active, and enabled
- [x] `qwen3-coder:30b` downloaded
- [x] Coding response generated successfully
- [x] Model reported as `100% GPU`
- [x] OpenClaw `contextWindow` set to `32768`
- [x] Ollama `num_ctx` set to `32768`

## OpenClaw local validation

- [x] OpenClaw `2026.7.1-2` installed
- [x] Node.js `24.18.0` installed
- [x] OpenClaw resolves from `/home/antonio/.npm-global/bin/openclaw`
- [x] Workspace created at `~/.openclaw/workspace`
- [x] Ollama provider configured as local-only
- [x] Ollama URL set to `http://127.0.0.1:11434`
- [x] Default model set to `ollama/qwen3-coder:30b`
- [x] Gateway token authentication enabled
- [x] Gateway bound to `127.0.0.1:18789`
- [x] Gateway systemd user service enabled
- [x] Gateway runtime active and RPC probe `ok`
- [x] Ollama and Gateway auto-start confirmed after reboot
- [x] Forge identity completed
- [x] Memory search disabled until a local provider is configured
- [x] Insecure Control UI authentication disabled
- [x] Cautious execution policy applied
- [x] Effective execution policy reports `security=allowlist` and `ask=on-miss`
- [x] Temporary web/browser provider deny removed

## Docker validation

- [x] Docker installed from the official Docker repository
- [x] Docker Engine version `29.6.2`
- [x] Docker Compose version `v5.3.1`
- [x] Docker service enabled and active
- [x] `hello-world` completed successfully
- [x] Administrator added to Docker group
- [x] `docker ps` works without `sudo` after reboot
- [x] Empty container list understood as expected

## OpenClaw sandbox validation

- [x] Image `openclaw-sandbox:bookworm-slim` built
- [x] Image includes Bash, curl, Git, jq, Python 3, ripgrep, and CA certificates
- [x] Container uses unprivileged `sandbox` user
- [x] Sandbox mode set to `all`
- [x] Backend set to `docker`
- [x] Scope set to `agent`
- [x] Workspace access set to `rw`
- [x] Docker network set to `bridge`
- [x] Configuration validates successfully
- [x] Gateway restarted after configuration
- [x] `sandbox explain` reports `runtime: sandboxed`
- [x] Host workspace maps to `/workspace`
- [x] `Dual_Boot_Share` is not mounted into the sandbox
- [x] No runtime exists before the first tool request, as expected
- [ ] Run first harmless read-only tool request
- [ ] Confirm approval prompt appears
- [ ] Confirm sandbox container appears in `openclaw sandbox list`
- [ ] Confirm command runs inside the container
- [ ] Confirm container cannot browse unrelated host paths
- [ ] Confirm outbound DNS and HTTPS access
- [ ] Rerun deep security audit

## Network readiness

- [ ] Self-hosted SearXNG configured
- [ ] Managed browser configured with deliberate permissions
- [ ] Stable LAN address reserved
- [ ] Trusted LAN access configured
- [ ] Guest and IoT isolation verified
- [ ] NetBird deployment audited
- [ ] Remote access tested
- [ ] OpenClaw access boundaries implemented
