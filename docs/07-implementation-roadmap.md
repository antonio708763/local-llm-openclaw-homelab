# Implementation Roadmap

## Phase 0 — Storage preparation

- [x] Back up Windows data
- [x] Repair NTFS
- [x] Resize Windows partition
- [x] Create approximately 500 GB `Dual_Boot_Share`
- [x] Confirm Ubuntu access

## Phase 1 — Host validation

- [ ] Confirm Ubuntu version and kernel
- [ ] Confirm `nvidia-smi` detects the RTX 4090
- [ ] Record the shared-partition UUID
- [ ] Configure a stable mount point
- [ ] Decide which folders OpenClaw may access

## Phase 2 — Ollama and model

- [ ] Install Ollama
- [ ] Pull `qwen3-coder:30b`
- [ ] Confirm GPU residency with `ollama ps`
- [ ] Benchmark 4K, 8K, and possibly 16K context
- [ ] Record performance and VRAM use

## Phase 3 — OpenClaw

- [ ] Install OpenClaw
- [ ] Configure Ollama's native API endpoint
- [ ] Set the workspace
- [ ] Enable authentication
- [ ] Keep command execution approval-required

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
