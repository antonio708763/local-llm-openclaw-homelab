# Local LLM + OpenClaw Homelab

A documented self-hosted AI workstation built around an RTX 4090, local Ollama models, and OpenClaw. The project now has two parallel assistant profiles:

- **Forge**: the stable, sandboxed coding/homelab assistant.
- **Power**: the higher-capability profile using an abliterated Qwen model and a remote Alienware node for hands-on lab work.

The current priority is to make Power pleasant and reliable enough for day-to-day project work before adding more infrastructure.

## Host system

- **Host OS:** Ubuntu, dual-booted with Windows 10
- **GPU:** NVIDIA RTX 4090, 24 GB VRAM
- **CPU:** AMD Ryzen 9 7950X
- **Memory:** 64 GB DDR5
- **Model runtime:** Ollama `0.32.3`
- **Agent layer:** OpenClaw `2026.7.1-2`
- **Container runtime:** Docker Engine `29.6.2`
- **Shared storage:** approximately 500 GB NTFS `Dual_Boot_Share` mounted at `/mnt/Dual_Boot_Share`
- **Trusted Linux client / first Power node:** `Alienware-15-R3`

## Forge and Power

| Item | Forge | Power |
|---|---|---|
| Role | Stable sandboxed assistant | High-capability local/lab assistant |
| Model | `qwen3-coder:30b` | `qwen3-abliterated:30b` |
| Gateway | `127.0.0.1:18789` | `127.0.0.1:19789` |
| Gateway auth | token | token |
| Workspace | `~/.openclaw/workspace` | `~/.openclaw/workspace-power` |
| Config | normal OpenClaw config | `~/.openclaw-power/openclaw.json` |
| Execution | Docker sandbox | Alienware node / full mode under active validation |
| Desktop launcher | `OpenClaw Forge` | `OpenClaw Power` |

## Current architecture

```text
                             RTX 4090 Ubuntu workstation

                         +-------------------------------+
                         | Ollama 127.0.0.1:11434        |
                         |                               |
                         | qwen3-coder:30b               |
                         | qwen3-abliterated:30b         |
                         +---------------+---------------+
                                         |
                     only one large model is intended to
                         remain loaded in VRAM at a time
                                         |
                    +--------------------+--------------------+
                    |                                         |
                    v                                         v
        +-------------------------+              +-------------------------+
        | Forge OpenClaw profile  |              | Power OpenClaw profile  |
        | Gateway 127.0.0.1:18789 |              | Gateway 127.0.0.1:19789 |
        | qwen3-coder:30b         |              | qwen3-abliterated:30b   |
        +------------+------------+              +------------+------------+
                     |                                          |
           +---------+---------+                     +----------+----------+
           |                   |                     |                     |
           v                   v                     v                     v
   Docker command      isolated browser       local browser UI      Alienware node
      sandbox              sandbox              launcher            over SSH tunnel
                                                                    127.0.0.1:19789
```

### Forge path

```text
OpenClaw Forge
    -> 127.0.0.1:18789
    -> Ollama qwen3-coder:30b
    -> Docker command sandbox
    -> isolated managed-browser container
```

Forge retains the original cautious design. Normal commands run in `openclaw-sandbox:bookworm-slim` as unprivileged user `sandbox`. The sandbox receives the OpenClaw workspace and only the dedicated `/mnt/Dual_Boot_Share/Forge_Shared` exchange folder.

### Power path

```text
OpenClaw Power
    -> 127.0.0.1:19789
    -> Ollama qwen3-abliterated:30b
    -> tools.exec host=node
    -> Alienware-15-R3
```

Power is intentionally separate from Forge. It has its own config, workspace, Gateway service, sessions, port, desktop launcher, SSH tunnel, and remote-node state.

## Models

### Forge model

```text
qwen3-coder:30b
```

Validated at `32768` context and `100% GPU` residency on the RTX 4090.

### Power model

Power uses the local Ollama alias:

```text
qwen3-abliterated:30b
```

created from:

```text
hf.co/mradermacher/Qwen3-30B-A3B-abliterated-erotic-i1-GGUF:Q4_K_M
```

Validated Power model details:

```text
Architecture:       qwen3moe
Parameters:         30.5B
Quantization:       Q4_K_M
Downloaded size:    about 18 GB
Context:            32768
Max output tokens:  8192
Ollama num_ctx:     32768
Processor:          100% GPU
Loaded size:        about 21 GB
```

A temporary `8192`-context test alias was used during GPU troubleshooting and then removed.

To avoid VRAM contention, `qwen3-coder:30b` and `qwen3-abliterated:30b` are not intended to stay loaded simultaneously.

## Forge milestones completed

- [x] Built the Windows/Ubuntu dual-boot storage layout.
- [x] Created and permanently mounted `Dual_Boot_Share`.
- [x] Installed and validated NVIDIA/CUDA and Ollama.
- [x] Installed OpenClaw `2026.7.1-2`.
- [x] Installed the loopback-only Forge Gateway on port `18789`.
- [x] Built and validated the Docker command sandbox.
- [x] Deployed self-hosted SearXNG on `127.0.0.1:8888`.
- [x] Built the isolated managed-browser image.
- [x] Created `/mnt/Dual_Boot_Share/Forge_Shared` and exposed only that folder to the command sandbox.
- [x] Created durable OpenClaw memory/checkpoint files.
- [x] Built persistent SSH trusted-client access from the Alienware.
- [x] Validated tunnel recovery after client reboot, Wi-Fi loss, Forge-host reboot, and established SSH-session termination.
- [x] Disabled SSH password and keyboard-interactive authentication.
- [x] Confirmed public-key-only SSH authentication.

## Power milestones completed

- [x] Downloaded the selected abliterated Qwen GGUF through Ollama.
- [x] Created `qwen3-abliterated:30b`.
- [x] Confirmed full RTX 4090 GPU residency.
- [x] Selected `32768` as the current Power context target.
- [x] Created the independent `power` OpenClaw profile.
- [x] Created `~/.openclaw-power/openclaw.json`.
- [x] Created `~/.openclaw/workspace-power`.
- [x] Created and enabled `openclaw-gateway-power.service`.
- [x] Kept the Power Gateway loopback-only on port `19789`.
- [x] Set `ollama/qwen3-abliterated:30b` as the Power default model.
- [x] Validated harmless direct write/modify/read/delete execution tests.
- [x] Created `OpenClaw Forge` and `OpenClaw Power` graphical launchers.
- [x] Created an Alienware SSH local-forward path for Power on port `19789`.
- [x] Upgraded the Alienware to matching OpenClaw `2026.7.1-2`.
- [x] Connected `Alienware-15-R3` as an OpenClaw Power node host.
- [x] Diagnosed that `devices list` shows operator devices, not node hosts.
- [x] Diagnosed and repaired a stale node pairing with empty capabilities/commands.
- [x] Approved a fresh Alienware node capability request.
- [x] Verified the node is paired, connected, approved, and advertising `browser`, `file`, `local-inference`, and `system` capabilities.
- [x] Applied node-side exec defaults from a JSON file.
- [x] Configured Power `tools.exec` to target `Alienware-15-R3` in full mode.

## Alienware Power node

The remote node uses an isolated state directory:

```text
~/.openclaw-power-node
```

A working foreground node connection requires the Power Gateway token in the node process environment:

```bash
OPENCLAW_GATEWAY_TOKEN="$POWER_TOKEN" \
OPENCLAW_STATE_DIR="$HOME/.openclaw-power-node" \
openclaw node run \
  --host 127.0.0.1 \
  --port 19789 \
  --display-name "Alienware-15-R3"
```

Expected:

```text
node host gateway connected: ws://127.0.0.1:19789
```

Important troubleshooting facts:

- `--no-tls` is not a valid option in OpenClaw `2026.7.1-2`; omit `--tls` for the SSH-forwarded plaintext loopback connection.
- `AUTH_TOKEN_MISSING` means the node process was started without `OPENCLAW_GATEWAY_TOKEN`.
- Brave choosing **Never save token** does not provide or remove the CLI node token.
- `openclaw --profile power devices list` is not the remote-node inventory.
- Use `nodes status`, `nodes pending`, `nodes approve`, and `nodes describe` for node hosts.
- A node can be connected yet unusable if an old pairing is stale.

The important stale-pairing signature was:

```text
paired: true
connected: true
approvalState: unapproved
caps: []
commands: []
pendingRequestId: none
```

The reliable recovery was to remove the stale Alienware node entry, restart the node with the correct token, wait for a fresh `nodes pending` request, approve that exact request, and verify capabilities with `nodes describe`.

See `docs/20-alienware-power-node.md` for the complete recovery sequence.

## Current Power exec configuration

Gateway-side Power exec target:

```json
{
  "host": "node",
  "mode": "full",
  "node": "Alienware-15-R3"
}
```

Alienware node-side approvals currently report:

```text
security=full
ask=off
askFallback=full
```

The node is now correctly paired and approved. The remaining problem is a later execution-policy layer: in the current browser test, `pwd` succeeded while `hostname` and `whoami` returned:

```text
SYSTEM_RUN_DENIED: approval required
```

That issue is still open. The working node pairing should not be torn down while debugging it.

## Current usability issues

These are the next priority before more infrastructure work:

1. **Visible Qwen thinking/reasoning output**
   - The Power UI can still display large reasoning blocks even when the model selector says `Off`.
   - Provider configuration already reports `reasoning=false` and `thinking=false`.
   - The next test is to disable thinking/reasoning at the OpenClaw session/default layer and verify a fresh chat.

2. **Context is being consumed too quickly**
   - Power is configured for `32768` tokens.
   - Large reasoning blocks, tool schemas, system context, and conversation history can consume the window after only a few useful messages.
   - The next step is to test `/status` and `/context list` in a clean Power session after reasoning is disabled, then tune compaction only if necessary.

3. **Alienware command approval mismatch**
   - Node pairing is healthy.
   - Power is configured for node/full mode.
   - Node defaults are full/off/full.
   - Some ordinary commands are still requesting approval.
   - This is the next remote-exec troubleshooting target after the thinking/context cleanup.

## Current checkpoint

As of August 10, 2026, this is no longer just a local model installation project. The working system has two distinct agent paths:

```text
Forge = stable, sandboxed, safer everyday assistant
Power = abliterated Qwen, separate profile, higher-capability lab assistant
```

Power can be opened graphically, its model runs fully on the RTX 4090, the Alienware reaches the Power Gateway through SSH, and the Alienware node is now correctly paired and capability-approved.

The project should not expand sideways into more infrastructure until the existing Power workflow is comfortable to use for real work. The immediate objective is to eliminate reasoning spam, make normal conversations last, and finish reliable Alienware execution.

## Planned inference-engine migration

Ollama remains the active runtime because it keeps model management and OpenClaw integration simple.

A future milestone is a side-by-side transition test to standalone `llama.cpp` for:

- more direct runtime visibility;
- finer control over context, KV cache, batching, and GPU offload;
- easier low-level debugging and benchmarking;
- earlier access to upstream optimizations;
- a smaller inference stack.

The migration must preserve OpenClaw compatibility, loopback-only exposure, model quality, context length, GPU acceleration, automatic startup, recovery behavior, and a tested rollback path to Ollama.

Qwen3.6-27B is also planned as a future model evaluation.

## Next tasks

1. Disable visible thinking/reasoning in Power and verify the change in a fresh session.
2. Inspect Power `/status` and `/context list`, then confirm several normal messages do not immediately exhaust the context window.
3. Resolve the Alienware `SYSTEM_RUN_DENIED: approval required` mismatch without resetting the now-working node pairing.
4. Convert the working Alienware node process into a reliable persistent service after command execution is proven.
5. Validate practical file and system-management workflows from the Power browser UI.
6. Start using Power for normal project work before adding additional infrastructure.
7. Later, define confirmation behavior for genuinely high-impact actions and add stronger audit/rollback controls.
8. Resume deferred Forge/SSH network hardening when it becomes useful.
9. Evaluate Qwen3.6-27B.
10. Benchmark Ollama against standalone `llama.cpp`.

## Repository map

```text
.
├── README.md
├── CHANGELOG.md
├── docs/
│   ├── 00-project-overview.md
│   ├── 01-hardware-and-os-layout.md
│   ├── 02-storage-layout.md
│   ├── 03-shared-partition-build-log.md
│   ├── 04-backup-and-recovery.md
│   ├── 05-network-access-plan.md
│   ├── 06-security-model.md
│   ├── 07-implementation-roadmap.md
│   ├── 08-validation-checklists.md
│   ├── 09-troubleshooting-log.md
│   ├── 10-ollama-and-model-validation.md
│   ├── 11-openclaw-local-onboarding.md
│   ├── 12-docker-and-sandbox.md
│   ├── 13-sandbox-runtime-validation.md
│   ├── 14-searxng-compaction-and-memory.md
│   ├── 15-managed-browser-and-security-audit.md
│   ├── 16-controlled-shared-folder-access.md
│   ├── 17-trusted-linux-client-ssh-tunnel.md
│   ├── 18-ssh-key-only-hardening.md
│   ├── 19-openclaw-power-profile.md
│   └── 20-alienware-power-node.md
├── docker/
│   └── openclaw-sandbox/
│       └── Dockerfile
├── scripts/
└── assets/screenshots/
```

## Repository rules

1. Never commit Gateway tokens, API keys, private SSH keys, SearXNG secret keys, or raw `openclaw.json` secrets.
2. Keep Forge and Power configuration/state separate.
3. Keep both Gateways loopback-only while SSH forwarding satisfies the access requirement.
4. Do not run both 30B-class models in VRAM unnecessarily.
5. Test remote-control changes on the Alienware lab node before expanding to additional devices.
6. Preserve the stable Forge path while Power is being tuned.
7. Keep documentation and troubleshooting history in Git so known failure modes are not rediscovered from scratch.
