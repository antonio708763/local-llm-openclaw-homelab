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

## Ollama and model validation

- [x] NVIDIA driver working
- [x] CUDA access verified
- [x] RTX 4090 visible
- [x] Sufficient free model storage
- [x] Ollama installed
- [x] Ollama service active and enabled
- [x] `qwen3-coder:30b` downloaded
- [x] Coding response generated successfully
- [x] Model reported as `100% GPU`
- [x] 32,768-token Ollama context allocation confirmed

## OpenClaw local validation

- [x] OpenClaw `2026.7.1-2` installed
- [x] Node.js `24.18.0` installed
- [x] OpenClaw command resolves from `/home/antonio/.npm-global/bin/openclaw`
- [x] Configuration written to `~/.openclaw/openclaw.json`
- [x] Configuration backup created as `~/.openclaw/openclaw.json.bak`
- [x] Workspace created at `~/.openclaw/workspace`
- [x] Main session directory created under `~/.openclaw/agents/main/sessions`
- [x] Ollama provider configured in local-only mode
- [x] Ollama URL configured as `http://127.0.0.1:11434`
- [x] Default model set to `ollama/qwen3-coder:30b`
- [x] Messaging channels skipped for initial testing
- [x] Web search skipped for initial testing
- [x] Gateway uses token authentication
- [x] Gateway bound to loopback on port `18789`
- [x] Gateway systemd user service enabled
- [x] Gateway runtime reported as active
- [x] RPC read probe reported `ok`
- [x] TUI connected to the main agent and main session
- [x] Ollama reported `active` at the stopping checkpoint
- [ ] Confirm Ollama and Gateway auto-start after reboot
- [ ] Complete identity/bootstrap conversation
- [ ] Review and restrict tool permissions
- [ ] Keep command execution approval-required
- [ ] Decide permitted filesystem paths
- [ ] Run a harmless tool-use test
- [ ] Investigate the TUI `262k` display versus the observed 32,768-token Ollama context

## Network readiness

- [ ] Stable LAN address reserved
- [ ] Trusted LAN access configured
- [ ] Guest and IoT isolation verified
- [ ] NetBird deployment audited
- [ ] Remote access tested
- [ ] OpenClaw access boundaries implemented
