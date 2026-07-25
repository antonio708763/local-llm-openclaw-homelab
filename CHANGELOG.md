# Changelog

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
- Screenshot evidence for OpenClaw installation, local Ollama onboarding, TUI connectivity, and Gateway health.

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
- Resolved the initial OpenClaw PATH issue by reloading `~/.bashrc`.
- Ran `openclaw onboard --install-daemon` using QuickStart.
- Selected Ollama in local-only mode.
- Configured `http://127.0.0.1:11434` without `/v1`.
- Selected `ollama/qwen3-coder:30b` as the default model.
- Skipped messaging channels and web search during the first local validation.
- Created the default workspace at `~/.openclaw/workspace`.
- Installed the Gateway as an enabled systemd user service.
- Confirmed the Gateway is loopback-only on port `18789` with token authentication.
- Confirmed the Gateway runtime is active, the RPC read probe is healthy, and Ollama is active.
- Connected to the main agent and main session using the OpenClaw TUI.

### Next

- Reboot Ubuntu and verify automatic startup of the shared mount, Ollama, and OpenClaw Gateway.
- Complete the OpenClaw identity/bootstrap conversation.
- Review tool permissions and keep execution approval-required.
- Decide which local and shared folders OpenClaw may access.
- Test one harmless local tool action.
- Investigate why the TUI displays `262k` tokens while Ollama previously reported a 32,768-token context allocation.
- Configure trusted LAN access only after local permissions are understood.
