# OpenClaw Power Profile

## Purpose

`Power` is a separate OpenClaw profile built for high-capability local experimentation, coding, programming, homelab automation, and future lab-computer control. It is intentionally kept separate from the normal `Forge` profile so the safer sandboxed workflow remains available while the higher-trust workflow can evolve independently.

This changed the project priority: usability and capability are being built first for Power, while additional hardening can be layered in after the workflow is useful in day-to-day work.

## Forge vs Power

| Item | Forge | Power |
|---|---|---|
| Purpose | Normal sandboxed assistant | High-capability local assistant |
| Primary model | `qwen3-coder:30b` | `qwen3-abliterated:30b` |
| Gateway | `127.0.0.1:18789` | `127.0.0.1:19789` |
| Command execution | Docker sandbox | Host/node-oriented, full execution policy under active testing |
| Workspace | `~/.openclaw/workspace` | `~/.openclaw/workspace-power` |
| Config | normal OpenClaw profile | `~/.openclaw-power/openclaw.json` |
| Gateway service | normal Forge gateway service | `openclaw-gateway-power.service` |
| Desktop launcher | `OpenClaw Forge` | `OpenClaw Power` |

Both profiles use the same local Ollama service, but they are separate OpenClaw instances with separate configuration, Gateway ports, sessions, and policy.

## Power model

The selected Power model is the local Ollama alias:

```text
qwen3-abliterated:30b
```

It was created from:

```text
hf.co/mradermacher/Qwen3-30B-A3B-abliterated-erotic-i1-GGUF:Q4_K_M
```

Validated model details observed during setup:

```text
Architecture:       qwen3moe
Parameters:         30.5B
Quantization:       Q4_K_M
Downloaded size:    about 18 GB
Power context:      32768
Power max tokens:   8192
Ollama num_ctx:     32768
Processor:          100% GPU
Loaded size:        about 21 GB
GPU:                RTX 4090
```

The underlying model advertises a larger native context, but Power is intentionally configured at `32768` for the current RTX 4090 build so the model and KV cache fit comfortably in VRAM.

## VRAM behavior

Only one large model should be kept loaded at a time. `qwen3-coder:30b` and `qwen3-abliterated:30b` are both retained in Ollama, but they are not intended to compete for VRAM simultaneously.

Useful checks:

```bash
ollama ps
nvidia-smi
```

Useful unload commands:

```bash
ollama stop qwen3-coder:30b
ollama stop qwen3-abliterated:30b
```

A temporary 8192-context GPU test alias was created during troubleshooting and later removed. The normal Power model remains the 32768-context alias.

## Power Gateway

Validated Power Gateway state:

```text
Profile:             power
Config:              ~/.openclaw-power/openclaw.json
Workspace:           ~/.openclaw/workspace-power
Gateway bind:        127.0.0.1
Gateway port:        19789
Authentication:      token
Service:             openclaw-gateway-power.service
Service state:       enabled + active
Dashboard:           HTTP 200 on 127.0.0.1:19789
Default model:       ollama/qwen3-abliterated:30b
```

The Gateway remains loopback-only. Remote trusted clients reach it through SSH local forwarding rather than a direct LAN bind.

## Desktop usability

Two graphical launchers were created on the RTX Ubuntu workstation:

```text
OpenClaw Forge
OpenClaw Power
```

The launchers open the corresponding browser-based OpenClaw dashboard, so normal use does not require manually typing OpenClaw terminal commands.

This is the intended day-to-day direction for the project: choose Forge or Power from the desktop, open a chat, and work from the browser UI.

## Power execution policy

Power was first validated with unrestricted local execution using the OpenClaw `yolo` exec-policy preset. Harmless write/modify/read/delete tests succeeded after the excessive model-thinking behavior was reduced.

The current Power execution target has since been moved to the Alienware node:

```json
{
  "host": "node",
  "mode": "full",
  "node": "Alienware-15-R3"
}
```

The Alienware node also has a node-side approvals file configured with:

```json
{
  "version": 1,
  "defaults": {
    "security": "full",
    "ask": "off",
    "askFallback": "full"
  }
}
```

The node is paired, connected, approved, and advertising system execution capabilities. Remote execution is still under active troubleshooting because some commands currently return `SYSTEM_RUN_DENIED: approval required` while a simple `pwd` request succeeds.

Do not treat remote execution as fully validated until this remaining approval mismatch is resolved.

## Thinking and context behavior

Two related usability problems were identified on August 10, 2026:

1. The abliterated Qwen model sometimes emits large visible reasoning blocks even when the UI model selector shows thinking as `Off`.
2. Those reasoning blocks and tool schemas consume the 32768-token context quickly, causing compaction or new-session prompts after only a small number of useful user messages.

Provider-level settings were already changed so the Power model reports:

```text
reasoning: false
thinking: false
contextWindow: 32768
num_ctx: 32768
```

However, visible reasoning still appeared in some OpenClaw tool runs. The next task is to disable reasoning at the OpenClaw session/default layer and retest context growth before changing the model context size.

Current troubleshooting plan:

```text
1. Disable /think and /reasoning in a fresh Power session.
2. Make the thinking/reasoning defaults persistent if the installed OpenClaw schema accepts them.
3. Inspect /status and /context list in a fresh session.
4. Confirm several normal messages no longer consume most of the context window.
5. Only then revisit compaction or a larger context configuration if needed.
```

## Current checkpoint

As of August 10, 2026:

- Power is a working independent OpenClaw profile.
- `qwen3-abliterated:30b` is the default Power model.
- The model is GPU accelerated on the RTX 4090.
- Power has its own loopback-only Gateway on port `19789`.
- Forge and Power have separate desktop launchers.
- The Alienware client can reach the Power dashboard through a dedicated SSH tunnel.
- The Alienware OpenClaw node is paired, connected, approved, and advertises system capabilities.
- Power is configured to target that node for execution.
- Remaining issues are visible reasoning/context churn and a node execution approval mismatch.

The next milestone is not more infrastructure expansion. It is to make the existing Power workflow pleasant enough for normal daily use, then finish remote-node execution validation.