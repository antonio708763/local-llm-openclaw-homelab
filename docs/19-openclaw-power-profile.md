# OpenClaw Power Profile

## Purpose

`Power` is a separate OpenClaw profile built for high-capability local experimentation, coding, programming, homelab automation, and remote lab-computer control. It is intentionally kept separate from the normal `Forge` profile so the safer sandboxed workflow remains available while the higher-trust workflow evolves independently.

The current project priority is usability first: make Power pleasant enough for normal daily conversation and work, then layer stronger confirmation/audit controls onto the already-functional workflow.

## Forge vs Power

| Item | Forge | Power |
|---|---|---|
| Purpose | Normal sandboxed assistant | High-capability local assistant |
| Primary model | `qwen3-coder:30b` | `qwen3-abliterated-nothink:30b` |
| Gateway | `127.0.0.1:18789` | `127.0.0.1:19789` |
| Command execution | Docker sandbox | Node-oriented, full mode under final validation |
| Workspace | `~/.openclaw/workspace` | `~/.openclaw/workspace-power` |
| Config | normal OpenClaw profile | `~/.openclaw-power/openclaw.json` |
| Gateway service | normal Forge gateway service | `openclaw-gateway-power.service` |
| Desktop launcher | `OpenClaw Forge` | `OpenClaw Power` |

Both profiles use the same local Ollama service, but they are separate OpenClaw instances with separate configuration, Gateway ports, sessions, and policy.

## Power model lineage

The original Power alias is:

```text
qwen3-abliterated:30b
```

It was created from:

```text
hf.co/mradermacher/Qwen3-30B-A3B-abliterated-erotic-i1-GGUF:Q4_K_M
```

Validated model details:

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

A second derived alias is now the normal Power default:

```text
qwen3-abliterated-nothink:30b
```

The original alias remains installed as a rollback/reference model.

## Why the no-think derivative was necessary

Provider-level configuration already reported:

```text
reasoning=false
thinking=false
```

and direct Ollama requests were tested with `"think": false`. Large visible reasoning blocks still appeared.

The key discovery was that the generated Ollama template itself prefilled a final opening `<think>` tag for the assistant turn. That meant the model could produce reasoning text inside ordinary content even when OpenClaw's visible reasoning control was off.

The final assistant prefill was changed from an opening `<think>` to an immediately closed block:

```text
<think></think>
```

The historical-message logic that can render a real `.Thinking` value was preserved.

The new model was created with:

```bash
ollama create qwen3-abliterated-nothink:30b \
  -f /tmp/qwen3-abliterated-nothink.modelfile
```

Direct validation showed:

```text
THINKING: None
CONTENT:  'NOTHINK_TEST_PASS'
```

A second test returned:

```text
THINKING: None
CONTENT:  '42'
```

OpenClaw also returned exactly:

```text
OPENCLAW_NOTHINK_PASS
```

and `/model status` showed the no-think alias as both Current and Default.

## VRAM behavior

Only one large model should be kept loaded at a time. `qwen3-coder:30b`, `qwen3-abliterated:30b`, and `qwen3-abliterated-nothink:30b` are retained in Ollama, but the 30B-class models are not intended to compete for VRAM simultaneously.

Useful checks:

```bash
ollama ps
nvidia-smi
```

Useful unload commands:

```bash
ollama stop qwen3-coder:30b
ollama stop qwen3-abliterated:30b
ollama stop qwen3-abliterated-nothink:30b
```

The no-think model has been observed at `32768` context, about 21 GB loaded, and `100% GPU` residency.

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
Default model:       ollama/qwen3-abliterated-nothink:30b
```

The Gateway remains loopback-only. Remote trusted clients reach it through SSH local forwarding rather than a direct LAN bind.

## Desktop usability

Two graphical launchers exist on the RTX Ubuntu workstation:

```text
OpenClaw Forge
OpenClaw Power
```

The intended day-to-day workflow is to choose Forge or Power from the desktop, open the browser UI, and work without manual terminal startup.

## Power execution policy

Power was first validated with unrestricted local execution using the OpenClaw `yolo` exec-policy preset. Harmless write/modify/read/delete tests succeeded.

The current execution target is the Alienware node:

```json
{
  "host": "node",
  "mode": "full",
  "node": "Alienware-15-R3"
}
```

The Alienware node has a node-side approvals file with:

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

The node is paired, connected, approved, and advertising `browser`, `file`, `local-inference`, and `system` capabilities. Pairing/capability approval is solved. Repeated harmless end-to-end command execution from the browser remains a final validation item.

## OpenClaw thinking defaults

Power now explicitly sets:

```text
agents.defaults.thinkingDefault = off
agents.defaults.reasoningDefault = off
```

A fresh Power status view reports thinking off. The separate no-think model is still required because the original visible reasoning problem came from the model template's forced assistant prefill, not only OpenClaw's reasoning-visibility setting.

## Compaction settings

The currently validated Power compaction configuration is:

```json
{
  "mode": "default",
  "reserveTokens": 8192,
  "keepRecentTokens": 6000,
  "reserveTokensFloor": 8192,
  "midTurnPrecheck": {
    "enabled": true
  }
}
```

This preserves output/tool headroom and keeps approximately 6,000 recent tokens verbatim when older history must be summarized.

## Context pruning and injection

Power also uses:

```text
agents.defaults.contextInjection = continuation-skip
agents.defaults.contextPruning.mode = cache-ttl
agents.defaults.contextPruning.ttl = 5m
skills.limits.maxSkillsPromptChars = 2500
```

A pre-optimization backup was created at:

```text
~/.openclaw-power/openclaw.json.before-context-optimization-20260811-004536.bak
```

## Context measurements

After the no-think fix and context tuning, a fresh session with only a handful of short messages still reported roughly:

```text
13k / 33k context
about 41%
```

Detailed context inspection showed approximately:

```text
System prompt run:          ~26.4k chars / ~6.6k tokens
Project context:            ~2.95k tokens
Tool schemas JSON:          20,985 chars / ~5.25k tokens
Actual cached context:      ~13.4k tokens
Untracked provider/runtime: ~1.6k tokens
```

The largest individual schema cost observed was `cron` at about 2.4K tokens. Other large entries included `skill_workshop`, `exec`, `sessions_spawn`, `process`, and `web_search`.

The skills prompt improved from about 17 skills / 1.49K tokens to about 10 skills / 611 tokens after setting `skills.limits.maxSkillsPromptChars=2500`.

## Architectural conclusion

The next problem is not "the model needs more context" by itself. Too much of the current 32K context is being spent before the user has had a real conversation.

The intended architecture is:

```text
Live context     = working memory
Durable memory   = long-term personal/project facts
Session history  = archive
Tool Search      = tools loaded only when relevant
Nodes            = remote-device hands
Compaction       = summarize older live conversation
```

Testing a 64K context remains planned, but only after reducing the baseline prompt. A larger window should provide more working room, not simply hold more idle schemas.

## Next milestone: Tool Search

The next Power task is to configure on-demand tool loading so ordinary conversation does not pay the full JSON-schema cost for tools such as cron, remote exec, session spawning, and web search on every turn.

Expected behavior:

```text
Normal conversation
    -> minimal tool overhead

File task
    -> load file/edit tooling

Alienware task
    -> load node/system tooling

Scheduled task
    -> load cron tooling
```

After Tool Search, the next major milestone is durable long-term memory and local semantic retrieval.

## Desired Power experience

The target workflow is:

```text
Open OpenClaw Power
    -> talk normally to qwen3-abliterated-nothink:30b
    -> thinking remains off by default
    -> relevant tools appear when needed
    -> stable facts live in durable memory
    -> older sessions remain searchable
    -> connected nodes perform approved work
    -> old chat is compacted instead of forcing constant new sessions
```

## Current checkpoint

As of August 11, 2026:

- Power is a working independent OpenClaw profile.
- `qwen3-abliterated-nothink:30b` is the default Power model.
- The original `qwen3-abliterated:30b` remains as a rollback/reference alias.
- The no-think model is GPU accelerated on the RTX 4090 and validated at 32768 context.
- Power has its own loopback-only Gateway on port `19789`.
- Forge and Power have separate desktop launchers.
- The Alienware client reaches Power through a dedicated SSH tunnel.
- The Alienware node is paired, connected, approved, and advertises system capabilities.
- Power targets the Alienware node for execution.
- Thinking/reasoning defaults are off.
- Compaction, context pruning, and skills-prompt limits are configured.
- The remaining major usability problem is baseline prompt/tool-schema overhead.

The next milestone is **Tool Search / on-demand tool loading**, followed by durable memory and retrieval.

See `docs/21-power-usability-context-and-memory.md` for the detailed no-think fix, token measurements, and next architecture plan.
