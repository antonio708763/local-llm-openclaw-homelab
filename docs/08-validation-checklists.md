# Validation Checklists

## Host and storage

- [x] Windows and Ubuntu remain on separate NVMe drives
- [x] Windows filesystem verified after resize
- [x] Approximately 500 GB `Dual_Boot_Share` created
- [x] `Dual_Boot_Share` mounted at `/mnt/Dual_Boot_Share`
- [x] NTFS read/write confirmed from Ubuntu
- [x] Automatic mount confirmed after Ubuntu reboot
- [x] RTX 4090 detected by `nvidia-smi`
- [x] NVIDIA driver and CUDA access validated
- [x] 64 GB system RAM available
- [ ] Confirm cross-OS file compatibility with files created from both operating systems

## Ollama

- [x] Ollama `0.32.3` installed
- [x] Ollama service enabled and active
- [x] Ollama bound locally
- [x] `qwen3-coder:30b` retained for Forge
- [x] `qwen3-abliterated:30b` retained for Power
- [x] Both large models individually validated on the RTX 4090
- [x] Power model validated at `32768` context
- [x] Forge model validated at `32768` context
- [x] Temporary 8192-context Power GPU-test alias removed
- [x] Workflow documented so only one 30B-class model needs to remain loaded at a time

## Forge OpenClaw profile

- [x] OpenClaw `2026.7.1-2` installed
- [x] Node.js `24.18.0` installed
- [x] Default Forge model is `ollama/qwen3-coder:30b`
- [x] Forge Gateway bound to `127.0.0.1:18789`
- [x] Gateway token authentication enabled
- [x] Forge Gateway systemd user service enabled
- [x] Forge and Ollama auto-start validated after reboot
- [x] Forge identity/bootstrap completed
- [x] Normal Forge exec host is the Docker sandbox
- [x] Compaction configured for the 32768-token Forge context
- [x] Durable `MEMORY.md` and dated memory notes created and verified
- [x] Fresh Forge session recalled durable project information

## Docker command sandbox

- [x] Docker Engine `29.6.2` installed from the official Docker repository
- [x] Docker Compose installed
- [x] `hello-world` completed successfully
- [x] `openclaw-sandbox:bookworm-slim` built
- [x] Commands run as unprivileged user `sandbox`
- [x] Container OS reports Debian 12
- [x] `/home/antonio` is not visible inside the sandbox
- [x] `/workspace` persists to the OpenClaw workspace
- [x] Outbound DNS works
- [x] Outbound HTTPS works

## Self-hosted search and managed browser

- [x] SearXNG deployed on `127.0.0.1:8888`
- [x] Persistent SearXNG configuration created
- [x] JSON search output enabled
- [x] OpenClaw SearXNG plugin installed and pinned to `@openclaw/searxng-plugin@2026.7.1`
- [x] `web_search` and `web_fetch` validated in a fresh Forge session
- [x] `openclaw-sandbox-browser:bookworm-slim` built
- [x] Browser sandbox uses a dedicated Docker network
- [x] Host-browser control disabled
- [x] Browser navigation, snapshot, and screenshot validated
- [x] Personal browser profiles not mounted
- [x] Browser does not receive the shared-folder bind
- [ ] Review and deliberately select SearXNG upstream engines

## Controlled shared-folder access

- [x] Created `/mnt/Dual_Boot_Share/Forge_Shared`
- [x] Mounted only `Forge_Shared` into the Forge command sandbox as `/forge-share:rw`
- [x] Browser bind list explicitly set to empty
- [x] Forge can read a host-created file from `/forge-share`
- [x] Forge can create a host-visible file in `/forge-share`
- [x] Rest of `Dual_Boot_Share` hidden from command sandbox
- [x] Host home hidden from command sandbox
- [x] Browser cannot see `/forge-share`
- [x] Browser cannot see `/mnt/Dual_Boot_Share`
- [x] Command and browser container mounts inspected directly

## Trusted Alienware SSH access

### Forge host

- [x] Trusted-LAN address reserved as `192.168.110.187`
- [x] OpenSSH Server installed and validated
- [x] Unused Samba services disabled
- [x] Ports 139 and 445 no longer listening
- [x] Forge Gateway remains loopback-only
- [x] Ollama remains loopback-only
- [x] SearXNG remains loopback-only
- [x] SSH, Ollama, and Forge Gateway return after a Forge-host reboot

### Alienware client

- [x] Ubuntu client identified as `user-Alienware-15-R3`
- [x] Dedicated `~/.ssh/openclaw_forge` Ed25519 key created
- [x] Public key installed on the RTX host
- [x] Key-only SSH login succeeded
- [x] Forge local forward `127.0.0.1:18789 -> RTX 127.0.0.1:18789` validated
- [x] Conflicting older local OpenClaw Gateway disabled
- [x] Remote Forge dashboard returned HTTP 200
- [x] Gateway token login succeeded through the tunnel
- [x] Existing Forge chat and durable memory opened remotely

### Persistent Forge tunnel

- [x] `forge-gateway-tunnel.service` created
- [x] Service enabled and active
- [x] `Restart=on-failure` configured
- [x] 30-second restart delay configured
- [x] User lingering enabled
- [x] Tunnel returned after client reboot
- [x] Tunnel recovered after Wi-Fi interruption
- [x] Tunnel recovered after Forge-host reboot
- [x] Tunnel recovered after established server-side SSH session termination

### SSH authentication hardening

- [x] Emergency dedicated-key access confirmed before hardening
- [x] Root-only OpenSSH configuration backup created
- [x] Password authentication disabled
- [x] Keyboard-interactive authentication disabled
- [x] Server confirmed to offer public-key authentication only
- [x] Hardened SSH configuration reloaded without rebooting the RTX host
- [x] Persistent Forge tunnel validated under the key-only policy
- [ ] Evaluate a dedicated restricted tunnel account
- [ ] Restrict SSH ingress with UFW
- [ ] Restrict SSH ingress with OPNsense policy
- [ ] Confirm Guest VLAN cannot reach TCP port 22
- [ ] Confirm IoT VLAN cannot reach TCP port 22
- [ ] Decide whether inherited root key login should be disabled completely

## Power OpenClaw profile

- [x] Selected Power model source `hf.co/mradermacher/Qwen3-30B-A3B-abliterated-erotic-i1-GGUF:Q4_K_M`
- [x] Created Ollama alias `qwen3-abliterated:30b`
- [x] Model reports `qwen3moe`, 30.5B parameters, Q4_K_M
- [x] Model downloaded size approximately 18 GB
- [x] Model validated at 100% GPU residency
- [x] Power context configured at `32768`
- [x] Power `maxTokens` configured at `8192`
- [x] Ollama `num_ctx` configured at `32768`
- [x] Separate OpenClaw `power` profile created
- [x] Power config stored at `~/.openclaw-power/openclaw.json`
- [x] Power workspace stored at `~/.openclaw/workspace-power`
- [x] Power Gateway bound to `127.0.0.1:19789`
- [x] Power Gateway token authentication enabled
- [x] `openclaw-gateway-power.service` enabled and active
- [x] Power dashboard returns HTTP 200 locally
- [x] Default model reports `ollama/qwen3-abliterated:30b`
- [x] Harmless full-host create/modify/read/delete exec test completed
- [x] `OpenClaw Forge` graphical launcher created
- [x] `OpenClaw Power` graphical launcher created
- [x] Power can be opened from the Ubuntu desktop without terminal configuration

## Power model behavior

- [x] Provider entry currently reports `reasoning=false`
- [x] Provider params currently report `thinking=false`
- [x] Power model context remains `32768`
- [ ] Verify a fresh Power session no longer prints large reasoning blocks
- [ ] Verify OpenClaw session/default thinking and reasoning controls persist across new sessions
- [ ] Inspect `/status` after a clean start
- [ ] Inspect `/context list` after a clean start
- [ ] Confirm several ordinary messages do not immediately consume most of the context window
- [ ] Retune Power compaction only if the clean-session test still requires it
- [ ] Increase model context only if 32768 remains insufficient after reasoning output is fixed

## Alienware Power tunnel

- [x] Power uses separate client loopback port `19789`
- [x] `power-gateway-tunnel.service` created on Alienware
- [x] Power tunnel returns HTTP 200 from the RTX Power Gateway
- [x] Forge tunnel on `18789` and Power tunnel on `19789` coexist
- [x] Gateway token can be retrieved through authenticated SSH when needed
- [x] No direct Power Gateway LAN bind introduced

## Alienware Power node host

- [x] Alienware OpenClaw upgraded to `2026.7.1-2`
- [x] `openclaw node` command family confirmed available
- [x] Isolated node state directory created at `~/.openclaw-power-node`
- [x] Node display name selected as `Alienware-15-R3`
- [x] Confirmed `--no-tls` is unsupported and unnecessary for the SSH-forwarded loopback connection
- [x] Diagnosed missing Gateway token error `AUTH_TOKEN_MISSING`
- [x] Node successfully connected using `OPENCLAW_GATEWAY_TOKEN`
- [x] Confirmed `devices list` operator entries are not remote node hosts
- [x] Node inspected with `nodes status --json`
- [x] Stale pairing diagnosed from `paired=true`, `connected=true`, `unapproved`, empty capabilities, and empty commands
- [x] Stale node pairing removed
- [x] Node reconnected and generated a fresh pending request
- [x] Fresh pending request approved
- [x] `nodes describe` reports `paired · connected`
- [x] `nodes describe` reports approval `approved`
- [x] Capabilities include `browser`, `file`, `local-inference`, and `system`
- [x] Commands include `system.run`, `system.run.prepare`, and `system.which`
- [x] Node approvals snapshot retrieved successfully
- [x] Node approvals updated successfully using `--file`
- [x] Node defaults report `security=full`, `ask=off`, `askFallback=full`

## Power remote exec targeting

- [x] Removed legacy `tools.exec.security` field before using `tools.exec.mode`
- [x] Removed legacy `tools.exec.ask` field before using `tools.exec.mode`
- [x] Set `tools.exec.host=node`
- [x] Set `tools.exec.mode=full`
- [x] Set `tools.exec.node=Alienware-15-R3`
- [x] Power configuration validates with the current exec schema
- [x] `pwd` executed successfully on the Alienware from the Power browser path
- [ ] Resolve `SYSTEM_RUN_DENIED: approval required` for `hostname`
- [ ] Resolve `SYSTEM_RUN_DENIED: approval required` for `whoami`
- [ ] Confirm a normal set of harmless system commands executes consistently
- [ ] Confirm harmless file create/read/modify/delete through the Power node
- [ ] Convert the working node process into a persistent service after foreground execution is reliable

## Power stopping point

Current priority order:

- [ ] 1. Disable visible thinking/reasoning output
- [ ] 2. Verify healthy conversation/context behavior
- [ ] 3. Resolve remaining remote-command approval mismatch
- [ ] 4. Make the Alienware node persistent
- [ ] 5. Begin using Power for normal project work
- [ ] 6. Add stronger confirmation/audit/rollback controls after the workflow is functionally useful

See also:

```text
docs/19-openclaw-power-profile.md
docs/20-alienware-power-node.md
```
