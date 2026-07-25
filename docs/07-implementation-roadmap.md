# Implementation Roadmap

## Phase 0 — Storage preparation

Status: **Complete**

- [x] Back up Windows data
- [x] Repair NTFS
- [x] Resize Windows partition
- [x] Create approximately 500 GB `Dual_Boot_Share`
- [x] Confirm Ubuntu access
- [x] Verify Windows data integrity after resizing

## Phase 1 — Host validation

Status: **Mostly complete**

- [x] Confirm `nvidia-smi` detects the RTX 4090
- [x] Verify NVIDIA driver and CUDA access
- [x] Record shared-partition UUID `48003BD2003BC62A`
- [x] Configure `/mnt/Dual_Boot_Share`
- [x] Confirm NTFS read/write access
- [ ] Confirm the mount automatically returns after an Ubuntu reboot
- [ ] Decide which shared folders OpenClaw may access

## Phase 2 — Ollama and model

Status: **Complete**

- [x] Install Ollama `0.32.3`
- [x] Confirm the Ollama systemd service is enabled and active
- [x] Pull `qwen3-coder:30b`
- [x] Run a coding prompt successfully
- [x] Confirm `100% GPU` residency with `ollama ps`
- [x] Confirm a 32,768-token Ollama context allocation
- [x] Record GPU utilization, temperature, and VRAM use

Validated result:

```text
Processor:       100% GPU
Context:         32768
VRAM:            21733 MiB / 24564 MiB
GPU utilization: 90%
Temperature:     47 C
```

## Phase 3 — OpenClaw local setup

Status: **Installed and connected; permissions testing remains**

- [x] Install OpenClaw `2026.7.1-2`
- [x] Install Node.js `24.18.0`
- [x] Reload the shell PATH after installation
- [x] Run onboarding with `openclaw onboard --install-daemon`
- [x] Use QuickStart
- [x] Select Ollama as the provider
- [x] Select local-only Ollama mode
- [x] Configure `http://127.0.0.1:11434`
- [x] Do not append `/v1`
- [x] Select `ollama/qwen3-coder:30b`
- [x] Create `~/.openclaw/workspace`
- [x] Skip messaging channels for initial testing
- [x] Skip web search for initial testing
- [x] Install the Gateway as a systemd user service
- [x] Enable token authentication
- [x] Keep the Gateway bound to loopback on port `18789`
- [x] Confirm TUI connectivity
- [x] Confirm Gateway runtime and RPC read probe
- [x] Confirm Ollama remains active
- [ ] Verify Gateway auto-start after reboot
- [ ] Complete the identity/bootstrap conversation
- [ ] Inspect active tool permissions
- [ ] Keep command execution approval-required
- [ ] Decide which local and shared folders are reachable
- [ ] Test local code generation through the agent
- [ ] Test one harmless local tool command
- [ ] Reconcile the TUI `262k` display with Ollama's observed 32,768-token allocation

## Phase 4 — LAN access

Status: **Not started**

- [ ] Reserve a stable DHCP address
- [ ] Decide whether OpenClaw should bind directly to the trusted LAN or sit behind a reverse proxy
- [ ] Keep token authentication enabled
- [ ] Configure host firewall rules
- [ ] Test from one trusted LAN computer
- [ ] Confirm Guest and IoT VLANs cannot connect
- [ ] Keep Ollama on loopback rather than exposing port `11434`

## Phase 5 — Remote access

Status: **Not started**

- [ ] Audit self-hosted NetBird
- [ ] Enroll the Ubuntu workstation and one remote client
- [ ] Confirm direct and relay connectivity
- [ ] Create an OpenClaw access group and policy
- [ ] Confirm no public OpenClaw port-forward is required

## Phase 6 — Controlled computer interaction

Status: **Not started**

- [ ] Choose a lab node
- [ ] Create a dedicated service account
- [ ] Enable read-only inventory first
- [ ] Add command allowlists and approvals
- [ ] Verify logging and rollback
- [ ] Expand permissions only after repeated successful lab tests
