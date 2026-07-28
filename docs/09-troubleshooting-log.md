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

## Browser build terminal closed immediately

The first browser-build block used:

```bash
set -euo pipefail
```

When a later command failed, Bash exited immediately. In a terminal window whose shell was the main process, that also closed the window.

Resolution: troubleshoot without `set -e`, test each step separately, and keep the terminal open long enough to inspect the failing command.

## npm returned an empty OpenClaw `gitHead`

The installed package version was detected correctly as `2026.7.1-2`, but:

```bash
npm view "openclaw@2026.7.1-2" gitHead
```

returned an empty value. That prevented constructing raw GitHub source URLs from a commit SHA.

Resolution:

1. Remove the package-republish suffix to obtain the base release `2026.7.1`.
2. Check candidate Git tags with `git ls-remote`.
3. Use the matching tag `v2026.7.1`.
4. Clone that tag and run the official browser setup script.

## Browser source clone tried to use `/openclaw`

The variable assignment accidentally began with a backslash:

```bash
\BUILD_DIR="$(mktemp -d)"
```

Bash treated the assignment as a command instead of setting `BUILD_DIR`. The variable stayed empty, so the clone destination became `/openclaw`, which failed with permission denied.

Resolution:

```bash
BUILD_DIR="/tmp/openclaw-browser-build"
rm -rf "$BUILD_DIR"

git clone \
  --depth 1 \
  --branch v2026.7.1 \
  https://github.com/openclaw/openclaw.git \
  "$BUILD_DIR"
```

Then:

```bash
cd "$BUILD_DIR"
bash scripts/sandbox-browser-setup.sh
```

## Browser image appeared empty while the build was running

Running this in a second terminal before the build completed showed only the headings:

```bash
docker images openclaw-sandbox-browser:bookworm-slim
```

This was expected. Docker does not tag the final image until the build succeeds. The build later completed and produced image ID `33fbbf1cd311`.

## Browser tool required two policy gates

The browser configuration was valid, but the tool still needed to be exposed globally and within the sandbox policy.

Resolution:

```bash
openclaw config set tools.alsoAllow '["browser"]' --strict-json

openclaw config set \
  tools.sandbox.tools.alsoAllow \
  '["web_search","web_fetch","browser"]' \
  --strict-json

openclaw config validate
openclaw gateway restart
```

A fresh TUI session then received the browser tool.

## Deep audit reported an unpinned SearXNG plugin

The plugin version was `2026.7.1`, but the recorded installation specification was the unversioned package name.

Resolution:

```bash
openclaw plugins install \
  npm:@openclaw/searxng-plugin@2026.7.1 \
  --pin \
  --force

openclaw gateway restart
```

Runtime inspection then showed:

```text
spec: @openclaw/searxng-plugin@2026.7.1
resolvedSpec: @openclaw/searxng-plugin@2026.7.1
```

The unpinned-plugin warning disappeared from the next deep audit.

## Managed-browser memory update did not complete

After the browser milestone, the direct Ubuntu verification showed:

- `MEMORY.md` still named managed-browser configuration as the next task.
- `memory/2026-07-28.md` did not exist.

This means the Forge write request did not complete even though the rest of the local evidence bundle was created.

Required follow-up:

1. Retry the memory write in a fresh TUI session.
2. Explicitly require the `read`, `write`, or `edit` tools.
3. Verify both files directly from Ubuntu before declaring the memory checkpoint complete.
