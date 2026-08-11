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

Status: **Complete for current Forge model**

- [x] Install Ollama `0.32.3`
- [x] Confirm the Ollama service is enabled and active
- [x] Pull `qwen3-coder:30b`
- [x] Run coding prompts successfully
- [x] Confirm `100% GPU` residency
- [x] Align OpenClaw context and Ollama `num_ctx` at `32768`

## Phase 3 — OpenClaw local setup

Status: **Complete for Forge**

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

Status: **Complete for the current Forge build**

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

Status: **Complete for Forge**

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

## Phase 7 — Trusted-LAN access

Status: **Core connectivity and SSH authentication complete; additional network hardening deferred**

- [x] Inventory Ubuntu interfaces, routes, Gateway settings, listening sockets, and firewall state
- [x] Reserve the Forge host at `192.168.110.187`
- [x] Select SSH local forwarding instead of a direct Gateway LAN bind or reverse proxy
- [x] Keep the OpenClaw Gateway bound to `127.0.0.1:18789`
- [x] Keep token authentication enabled
- [x] Keep Ollama on loopback
- [x] Keep SearXNG on loopback
- [x] Avoid public port forwarding
- [x] Disable unused Samba services on the Forge host
- [x] Install and validate OpenSSH Server on the Forge host
- [x] Create a dedicated Ed25519 key on the trusted Linux client
- [x] Install and validate the client public key
- [x] Create the `forge-gateway` SSH profile with a loopback-only local forward
- [x] Disable the conflicting older local OpenClaw Gateway on the client
- [x] Confirm the client tunnel returns HTTP 200 from the remote dashboard
- [x] Log in through the tunnel using the Forge Gateway token
- [x] Create and enable `forge-gateway-tunnel.service`
- [x] Enable systemd user lingering on the client
- [x] Reboot the client and confirm automatic tunnel restoration
- [x] Confirm the client can open the existing Forge chat and durable memory
- [x] Test tunnel recovery after Wi-Fi interruption
- [x] Test tunnel recovery after a Forge-host restart
- [x] Test recovery after terminating the established server-side SSH tunnel process
- [x] Confirm emergency access with the dedicated key
- [x] Disable SSH password authentication
- [x] Disable keyboard-interactive authentication
- [x] Confirm the server offers public-key authentication only
- [ ] Evaluate a dedicated restricted tunnel account
- [ ] Restrict SSH ingress with UFW and OPNsense
- [ ] Confirm Guest and IoT VLANs cannot reach the Forge host SSH service
- [ ] Decide whether to disable inherited root key login completely

## Phase 8 — Remote access

Status: **Not started**

- [ ] Audit self-hosted NetBird
- [ ] Enroll the Ubuntu workstation and one remote client
- [ ] Confirm direct and relay connectivity
- [ ] Create an OpenClaw access group and policy
- [ ] Confirm no public port-forward is required
- [ ] Reuse the SSH-forward design over the approved encrypted overlay where practical

## Phase 9 — Controlled interaction with other computers

Status: **Superseded by the Power-first prototype on the Alienware lab node**

The original plan was to build a restricted remote-control path before the high-capability assistant. The project priority changed: establish a functional Power workflow first, test it on the Alienware lab computer, then add stronger restrictions after the workflow is useful.

- [x] Choose a lab node: `Alienware-15-R3`
- [x] Establish authenticated SSH transport to the RTX host
- [x] Install matching OpenClaw `2026.7.1-2` on the Alienware
- [x] Create an isolated Power node state directory
- [x] Connect the Alienware node to the Power Gateway through port `19789`
- [x] Repair stale node pairing and approve a fresh capability request
- [x] Confirm the node is paired, connected, approved, and advertises system capabilities
- [ ] Resolve the remaining per-command execution approval mismatch
- [ ] Convert the working foreground node process into a reliable persistent service
- [ ] Validate file operations and harmless system administration from Power
- [ ] Add explicit confirmation behavior for genuinely high-impact operations after the basic workflow is stable

## Phase 10 — Separate abliterated OpenClaw Power instance

Status: **In progress and currently prioritized**

Selected model source:

```text
hf.co/mradermacher/Qwen3-30B-A3B-abliterated-erotic-i1-GGUF:Q4_K_M
```

Local Power alias:

```text
qwen3-abliterated:30b
```

### Completed

- [x] Pull the abliterated Qwen GGUF through Ollama
- [x] Create the local alias `qwen3-abliterated:30b`
- [x] Confirm Q4_K_M model details and GPU acceleration
- [x] Confirm the model can run at `32768` context on the RTX 4090
- [x] Avoid simultaneous residency of multiple 30B-class models
- [x] Create the separate OpenClaw `power` profile
- [x] Create separate config at `~/.openclaw-power/openclaw.json`
- [x] Create separate workspace at `~/.openclaw/workspace-power`
- [x] Create separate Gateway on `127.0.0.1:19789`
- [x] Install and enable `openclaw-gateway-power.service`
- [x] Set `ollama/qwen3-abliterated:30b` as the default Power model
- [x] Set Power model context and Ollama `num_ctx` to `32768`
- [x] Validate direct host exec with harmless create/modify/read/delete tests
- [x] Create separate graphical `OpenClaw Forge` and `OpenClaw Power` launchers
- [x] Create an Alienware Power SSH tunnel on port `19789`
- [x] Upgrade the Alienware OpenClaw client to `2026.7.1-2`
- [x] Connect `Alienware-15-R3` as a Power node host
- [x] Diagnose the difference between operator devices and node hosts
- [x] Repair the stale pairing that produced empty capabilities and commands
- [x] Approve a fresh node request and verify capabilities
- [x] Apply node-side exec defaults using a JSON file
- [x] Configure Power `tools.exec` for the Alienware node

### Current usability problems

- [ ] Stop visible Qwen reasoning blocks from flooding normal Power chats
- [ ] Verify thinking/reasoning is disabled persistently for new Power sessions
- [ ] Retest compaction and context growth in a fresh 32768-token session
- [ ] Confirm more than a few normal messages can be exchanged without forced session replacement
- [ ] Resolve `SYSTEM_RUN_DENIED: approval required` for ordinary Alienware commands such as `hostname` and `whoami`
- [ ] Confirm Power can reliably run harmless commands on the Alienware without random approval mismatches

### After the workflow is usable

- [ ] Define which actions require explicit confirmation
- [ ] Add visible command/audit logging that is easy to review
- [ ] Add a hard-stop/emergency-disable procedure independent of the model
- [ ] Expand device access only after repeated successful lab tests
- [ ] Revisit security hardening after the functionality baseline is stable

See:

```text
docs/19-openclaw-power-profile.md
docs/20-alienware-power-node.md
```

## Phase 11 — Future model and inference experiments

Status: **Planned**

- [ ] Add and evaluate Qwen3.6-27B as a future model option
- [ ] Benchmark Ollama against a standalone `llama.cpp` server
- [ ] Transition the inference backend only after compatibility, performance, context, GPU acceleration, startup, recovery, and rollback validation succeeds
- [ ] Preserve Ollama as a known-good rollback path during the transition
