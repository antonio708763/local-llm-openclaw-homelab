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

### Completed

- Verified Windows data integrity after the partition resize.
- Configured `Dual_Boot_Share` at `/mnt/Dual_Boot_Share` using UUID `48003BD2003BC62A`.
- Confirmed NTFS read/write access from Ubuntu using the `ntfs3` driver.
- Verified NVIDIA driver and CUDA access.
- Installed Ollama `0.32.3` as an enabled systemd service.
- Downloaded `qwen3-coder:30b`.
- Confirmed `100% GPU` model residency on the RTX 4090.
- Validated a 32,768-token context allocation with approximately 21.7 GiB of VRAM in use.

### Next

- Install OpenClaw.
- Connect OpenClaw to Ollama's native API at `http://127.0.0.1:11434`.
- Keep tool execution approval-required during initial testing.
