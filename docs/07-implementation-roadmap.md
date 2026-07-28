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
- [x] Disable broken OpenAI-backed semantic memory search
- [x] Disable insecure Control UI authentication
- [x] Tune compaction for the 32,768-token context
- [x] Create durable memory files
- [x] Verify durable memory across a fresh session

## Phase 4 — Docker command sandbox

Status: **Complete**

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

## Phase 5 — Web research and managed browser

Status: **Complete**

- [x] Install the OpenClaw SearXNG plugin
- [x] Deploy a self-hosted SearXNG instance
- [x] Bind SearXNG to `127.0.0.1:8888`
- [x] Persist SearXNG configuration outside the container
- [x] Enable SearXNG JSON search output
- [x] Configure OpenClaw web search to use SearXNG
- [x] Add `web_search` and `web_fetch` to the sandbox allowlist
- [x] Test current-information retrieval in a fresh session
- [x] Pin SearXNG to `@openclaw/searxng-plugin@2026.7.1`
- [x] Build `openclaw-sandbox-browser:bookworm-slim`
- [x] Configure OpenClaw's managed browser separately
- [x] Add `browser` to both required tool-policy gates
- [x] Disable host-browser control
- [x] Use a dedicated browser Docker network
- [x] Open and inspect a test page
- [x] Generate a browser snapshot and screenshot
- [x] Verify browser screenshot persistence
- [x] Keep the managed browser separate from personal browser profiles
- [x] Review sandbox-browser mounts and isolation
- [x] Rerun `openclaw security audit --deep`
- [x] Record the accepted small-model web-input risk
- [x] Record that `trustedProxies` needs no action while the Gateway is loopback-only
- [ ] Review and deliberately select SearXNG upstream engines

## Phase 5A — Memory and evidence housekeeping

Status: **Complete for current milestones**

- [x] Update the durable `MEMORY.md` current checkpoint
- [x] Create and verify `memory/2026-07-28.md`
- [x] Verify both memory files directly from Ubuntu
- [x] Create local managed-browser evidence bundle
- [x] Create local controlled-share evidence bundle
- [ ] Review both local evidence bundles for secrets
- [ ] Commit only safe, selected evidence artifacts

## Phase 6 — Controlled filesystem access

Status: **Complete**

- [x] Create `/mnt/Dual_Boot_Share/Forge_Shared`
- [x] Select read/write access for the dedicated exchange folder
- [x] Enable external Docker bind sources deliberately
- [x] Mount only `Forge_Shared` into the command sandbox as `/forge-share:rw`
- [x] Explicitly set browser binds to an empty array
- [x] Recreate command and browser sandbox runtimes
- [x] Confirm Forge can read a host-created file
- [x] Confirm Forge can create a host-visible file
- [x] Confirm Forge cannot reach the rest of `Dual_Boot_Share`
- [x] Confirm Forge cannot reach `/home/antonio`
- [x] Inspect actual command-container mounts
- [x] Inspect actual browser-container mounts
- [x] Confirm the browser cannot see `/forge-share`
- [x] Confirm the browser cannot see `/mnt/Dual_Boot_Share`
- [x] Document rollback commands
- [x] Update durable memory and create checkpoint evidence

## Phase 7 — LAN access

Status: **Next phase**

- [ ] Inventory Ubuntu interfaces, routes, Gateway settings, listening sockets, and firewall state
- [ ] Reserve a stable DHCP address
- [ ] Decide whether OpenClaw binds directly to the trusted LAN or sits behind a reverse proxy
- [ ] Keep token authentication enabled
- [ ] Configure host firewall rules
- [ ] Test from one trusted LAN computer
- [ ] Confirm Guest and IoT VLANs cannot connect
- [ ] Keep Ollama on loopback
- [ ] Avoid public port forwarding

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
