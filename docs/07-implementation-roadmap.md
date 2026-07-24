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
- [x] Confirm a 32,768-token context allocation
- [x] Record GPU utilization, temperature, and VRAM use

Validated result:

```text
Processor:       100% GPU
Context:         32768
VRAM:            21733 MiB / 24564 MiB
GPU utilization: 90%
Temperature:     47 C
```

## Phase 3 — OpenClaw

Status: **Next**

- [ ] Install OpenClaw
- [ ] Configure Ollama's native endpoint as `http://127.0.0.1:11434`
- [ ] Do not append `/v1`
- [ ] Set the OpenClaw workspace
- [ ] Enable authentication
- [ ] Keep command execution approval-required
- [ ] Test local code generation
- [ ] Test one harmless local tool command

## Phase 4 — LAN access

- [ ] Reserve a stable DHCP address
- [ ] Configure host firewall rules
- [ ] Test from a trusted LAN computer
- [ ] Confirm Guest and IoT VLANs cannot connect

## Phase 5 — Remote access

- [ ] Audit self-hosted NetBird
- [ ] Enroll the Ubuntu workstation and one remote client
- [ ] Confirm direct and relay connectivity
- [ ] Create an OpenClaw access group and policy

## Phase 6 — Controlled computer interaction

- [ ] Choose a lab node
- [ ] Create a dedicated service account
- [ ] Enable read-only inventory first
- [ ] Add command allowlists and approvals
- [ ] Verify logging and rollback
