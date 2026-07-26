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

Status: **Complete**

- [x] Confirm `nvidia-smi` detects the RTX 4090
- [x] Verify NVIDIA driver and CUDA access
- [x] Record shared-partition UUID `48003BD2003BC62A`
- [x] Configure `/mnt/Dual_Boot_Share`
- [x] Confirm NTFS read/write access
- [x] Confirm the mount automatically returns after an Ubuntu reboot

## Phase 2 — Ollama and model

Status: **Complete**

- [x] Install Ollama `0.32.3`
- [x] Confirm the Ollama service is enabled and active
- [x] Pull `qwen3-coder:30b`
- [x] Run coding prompts successfully
- [x] Confirm `100% GPU` residency
- [x] Align OpenClaw context and Ollama `num_ctx` at `32768`

## Phase 3 — OpenClaw local setup

Status: **Complete**

- [x] Install OpenClaw `2026.7.1-2`
- [x] Install Node.js `24.18.0`
- [x] Configure local Ollama at `http://127.0.0.1:11434`
- [x] Select `ollama/qwen3-coder:30b`
- [x] Create `~/.openclaw/workspace`
- [x] Install the Gateway as a systemd user service
- [x] Enable token authentication
- [x] Keep the Gateway bound to loopback on port `18789`
- [x] Confirm Gateway and Ollama auto-start after reboot
- [x] Complete Forge's identity/bootstrap conversation
- [x] Apply cautious command execution policy
- [x] Set normal execution host to `sandbox`
- [x] Disable broken OpenAI-backed memory search
- [x] Disable insecure Control UI authentication

## Phase 4 — Docker sandbox

Status: **Runtime validation complete**

- [x] Install Docker Engine from Docker's official Ubuntu repository
- [x] Install Docker Compose plugin
- [x] Validate with `hello-world`
- [x] Add the administrator account to the Docker group
- [x] Reboot and verify non-root Docker access
- [x] Build `openclaw-sandbox:bookworm-slim`
- [x] Configure sandbox mode `all`
- [x] Configure Docker backend and agent scope
- [x] Configure read/write workspace access
- [x] Configure bridge networking
- [x] Confirm effective runtime reports `sandboxed`
- [x] Run the first harmless tool command
- [x] Confirm the container is created automatically
- [x] Confirm commands run as unprivileged user `sandbox`
- [x] Confirm container OS is Debian 12
- [x] Verify `/home/antonio` is not visible
- [x] Verify workspace writes persist to the host workspace
- [x] Verify outbound DNS resolution
- [x] Verify outbound HTTPS access
- [ ] Rerun `openclaw security audit --deep` after web and browser configuration

## Phase 5 — Web research and managed browser

Status: **Next**

- [ ] Deploy a self-hosted SearXNG instance
- [ ] Enable SearXNG JSON search output
- [ ] Configure OpenClaw web search to use SearXNG
- [ ] Decide which upstream search engines SearXNG may query
- [ ] Test current-information retrieval
- [ ] Configure OpenClaw's managed browser separately
- [ ] Explicitly allow only the browser capabilities needed
- [ ] Keep the managed browser separate from the personal browser profile
- [ ] Review sandbox and browser isolation

## Phase 6 — Controlled filesystem access

Status: **Not started**

- [ ] Decide which `Dual_Boot_Share` folders Forge may access
- [ ] Mount only selected paths into the sandbox
- [ ] Start read-only where practical
- [ ] Test file creation in a dedicated project folder
- [ ] Confirm Forge cannot reach unrelated host data

## Phase 7 — LAN access

Status: **Not started**

- [ ] Reserve a stable DHCP address
- [ ] Decide whether OpenClaw binds to the trusted LAN or sits behind a reverse proxy
- [ ] Keep token authentication enabled
- [ ] Configure firewall rules
- [ ] Test from one trusted LAN computer
- [ ] Confirm Guest and IoT VLANs cannot connect
- [ ] Keep Ollama on loopback

## Phase 8 — Remote access

Status: **Not started**

- [ ] Audit self-hosted NetBird
- [ ] Enroll the Ubuntu workstation and one remote client
- [ ] Confirm direct and relay connectivity
- [ ] Create an OpenClaw access group and policy
- [ ] Confirm no public port-forward is required

## Phase 9 — Controlled interaction with other computers

Status: **Not started**

- [ ] Choose a lab node
- [ ] Create a dedicated service account
- [ ] Enable read-only inventory first
- [ ] Add command allowlists and approvals
- [ ] Verify logging and rollback
- [ ] Expand permissions only after repeated successful lab tests
