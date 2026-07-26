# Troubleshooting Log

## Shared partition could not expand

The original unallocated space was before `Dual_Boot_Share`. Windows Disk Management only extends into adjacent unallocated space on the right.

## Windows C: showed 0 MB available to shrink

Investigated page file, crash dumps, hibernation, Fast Startup, NTFS errors, and fragmented free space.

```powershell
chkdsk C: /scan
chkdsk C: /spotfix
chkdsk C: /scan
defrag C: /X /U /V
```

The filesystem became clean, but unmovable NTFS metadata still blocked Disk Management. The unmounted partition was resized successfully with GParted.

## GParted initially showed the wrong NVMe

Multiple drives had similar capacities and Linux NVMe numbering changed between boots. The Windows drive was identified using its EFI, Microsoft Reserved, and large NTFS partition layout.

## Robocopy could not open its log

The log's parent directory did not exist. It was created first:

```powershell
New-Item -ItemType Directory -Path "E:\Before-C-Resize-Backup" -Force
```

## SearXNG JSON search returned HTTP 403

The SearXNG HTML interface worked, but this request failed:

```bash
curl -fsS 'http://127.0.0.1:8888/search?q=OpenClaw&format=json'
```

Cause: the default container configuration did not permit JSON output.

Resolution: create a persistent `~/searxng/settings.yml` file and enable both formats:

```yaml
use_default_settings: true

search:
  formats:
    - html
    - json
```

The container was recreated with the settings file mounted read-only at `/etc/searxng/settings.yml`. The JSON request then returned search results.

## Forge could not see the `web_search` tool

SearXNG and the plugin were working, but the new tool was absent from Forge's available-tool list.

Cause: the sandbox tool policy had an additional allow gate.

Resolution:

```bash
openclaw config set \
  tools.sandbox.tools.alsoAllow \
  '["web_search","web_fetch"]' \
  --strict-json

openclaw config validate
openclaw gateway restart
```

A fresh TUI session then exposed `web_search`, and Forge completed a successful search through SearXNG.

## Auto-compaction could not recover the session

OpenClaw repeatedly displayed an auto-compaction warning even though the visible conversation counter was low.

The detailed context inspection showed that system instructions, injected workspace files, skills, and tool schemas consumed substantial hidden context. The tracked startup estimate was approximately 8,929 tokens before normal conversation growth.

For the 32,768-token local model, compaction was tuned to:

```json
{
  "reserveTokens": 8192,
  "keepRecentTokens": 6000,
  "reserveTokensFloor": 8192
}
```

Commands:

```bash
openclaw config set agents.defaults.compaction.reserveTokens 8192 --strict-json
openclaw config set agents.defaults.compaction.reserveTokensFloor 8192 --strict-json
openclaw config set agents.defaults.compaction.keepRecentTokens 6000 --strict-json
openclaw config validate
openclaw gateway restart
```

After tuning, Forge successfully wrote the durable memory files.

## Forge said information was stored without proving a file write

A conversational acknowledgement is not proof that long-term memory was updated.

Resolution:

1. Explicitly instruct Forge to use `read`, `write`, or `edit`.
2. Provide the exact `/workspace/MEMORY.md` and dated-note paths.
3. Verify the files directly from Ubuntu:

```bash
cat ~/.openclaw/workspace/MEMORY.md
cat ~/.openclaw/workspace/memory/2026-07-26.md
```

A fresh session was then used to prove that durable information was loaded from disk.
