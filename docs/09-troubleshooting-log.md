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

After the browser milestone, the first direct Ubuntu verification showed:

- `MEMORY.md` still named managed-browser configuration as the next task.
- `memory/2026-07-28.md` did not exist.

The Forge request had not completed even though the local evidence bundle was created.

Resolution:

1. Back up the existing `MEMORY.md`.
2. Update only the `Current Project Checkpoint` section from Ubuntu with a small Python script.
3. Create `memory/2026-07-28.md` directly.
4. Verify both files with `grep`, `cat`, and `ls`.

The repair succeeded. The backup was preserved as:

```text
~/.openclaw/workspace/MEMORY.md.before-managed-browser-update.bak
```

## Old TUI session exceeded the model context window

During the first controlled-share test, the TUI ended with:

```text
run error: LLM request failed
tokens 119k/33k (365%)
```

This was not a filesystem or bind-mount failure. The old session had accumulated far more history than the 32,768-token model could process.

Resolution:

1. Open the TUI.
2. Use `/new` to create a fresh session.
3. Repeat only the short validation commands.

The fresh session completed the controlled-share tests successfully.

## Sandbox recreate reported no matching runtimes

The command and browser sandbox runtimes were removed successfully on the first recreate pass. The same recreate commands were then run a second time and reported:

```text
No sandbox runtimes found matching the criteria.
```

This was harmless. There were no old containers left to remove, and OpenClaw recreated the runtimes automatically when Forge next used the exec and browser tools.

## External bind required explicit opt-in

`Forge_Shared` is outside `~/.openclaw/workspace`, so the command sandbox required explicit permission to use an external bind source:

```bash
openclaw config set \
  agents.defaults.sandbox.docker.dangerouslyAllowExternalBindSources \
  true \
  --strict-json
```

Only the dedicated directory was then mounted:

```bash
openclaw config set \
  agents.defaults.sandbox.docker.binds \
  '["/mnt/Dual_Boot_Share/Forge_Shared:/forge-share:rw"]' \
  --strict-json
```

The dangerous-sounding option does not itself mount a drive. It permits the explicitly configured external source. The safety boundary depends on keeping the bind list narrow.

## Browser could have inherited command-sandbox binds

The command sandbox needed `Forge_Shared`, but the browser did not.

Resolution: explicitly set the browser bind list to an empty array instead of relying on defaults:

```bash
openclaw config set \
  agents.defaults.sandbox.browser.binds \
  '[]' \
  --strict-json
```

Direct mount inspection and container-level path tests later confirmed that the browser could not see `/forge-share` or `/mnt/Dual_Boot_Share`.

## Controlled-share validation

The final validation proved:

```text
PASS_ENTIRE_SHARE_HIDDEN
PASS_HOST_HOME_HIDDEN
PASS: browser cannot see Forge_Shared
PASS: browser cannot see Dual_Boot_Share
```

The command container had exactly one external data mount:

```text
/mnt/Dual_Boot_Share/Forge_Shared -> /forge-share (read/write)
```

The browser container had no external data mount.
