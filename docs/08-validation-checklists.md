# Validation Checklists

## Windows post-resize

The user confirmed Windows data integrity after the resize.

- [x] Windows boots normally
- [x] `chkdsk C: /scan` reports no problems
- [x] Important files remain accessible
- [x] Important applications remain usable
- [x] Archive drives are visible
- [x] `Dual_Boot_Share` appears as `H:`
- [x] Files can be created and read on `H:`

## Ubuntu post-resize

- [x] Ubuntu boots normally
- [x] `Dual_Boot_Share` appears in Files
- [x] Recorded UUID `48003BD2003BC62A`
- [x] Configured `/mnt/Dual_Boot_Share`
- [x] Confirmed read/write access
- [x] Created `ubuntu-write-test.txt`
- [ ] Confirm automatic mount after reboot
- [ ] Confirm cross-OS file compatibility using files created from both operating systems

## Backup validation

- [x] Important Windows data was backed up to `SSD_Archive(1)` before resizing
- [ ] Keep the pre-resize backup until several normal Windows and Ubuntu boots have completed

## Local LLM readiness

- [x] NVIDIA driver working
- [x] CUDA access verified
- [x] RTX 4090 visible
- [x] Sufficient free model storage
- [x] Shared workspace storage mounted
- [x] Ollama installed
- [x] Ollama service active and enabled
- [x] `qwen3-coder:30b` downloaded
- [x] Coding response generated successfully
- [x] Model reported as `100% GPU`
- [x] 32,768-token context allocation confirmed
- [ ] Stable LAN address reserved
- [ ] OpenClaw installed
- [ ] OpenClaw access boundaries implemented
