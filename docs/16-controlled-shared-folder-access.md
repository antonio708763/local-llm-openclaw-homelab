# Controlled Shared-Folder Access

## Goal

Give Forge read/write access to one deliberately selected directory on the dual-boot NTFS partition without exposing the rest of `Dual_Boot_Share`, the Ubuntu home directory, or the shared folder to the managed browser.

The boundary is:

```text
Ubuntu host
  /mnt/Dual_Boot_Share/Forge_Shared
                    |
                    | Docker bind mount, read/write
                    v
OpenClaw command sandbox
  /forge-share
```

The browser sandbox does not receive this bind mount.

## Host preparation

The dedicated directory and a host-side test file were created:

```bash
mkdir -p /mnt/Dual_Boot_Share/Forge_Shared

printf '%s\n' \
  'Created by Antonio on the Ubuntu host.' \
  > /mnt/Dual_Boot_Share/Forge_Shared/host-created.txt
```

The parent NTFS partition was confirmed mounted read/write:

```bash
findmnt /mnt/Dual_Boot_Share
```

Observed mount:

```text
Source:  /dev/nvme2n1p4
Target:  /mnt/Dual_Boot_Share
Type:    ntfs3
Options: rw,relatime,uid=1000,gid=1000,dmask=0022,fmask=0022,iocharset=utf8
```

The dedicated folder and test file were readable from Ubuntu.

## Command-sandbox configuration

External bind sources were enabled because `Forge_Shared` is outside the normal OpenClaw workspace:

```bash
openclaw config set \
  agents.defaults.sandbox.docker.dangerouslyAllowExternalBindSources \
  true \
  --strict-json
```

Only the dedicated folder was mounted into the command sandbox:

```bash
openclaw config set \
  agents.defaults.sandbox.docker.binds \
  '["/mnt/Dual_Boot_Share/Forge_Shared:/forge-share:rw"]' \
  --strict-json
```

The entire partition was not mounted.

## Browser isolation

The browser bind list was explicitly set to an empty array:

```bash
openclaw config set \
  agents.defaults.sandbox.browser.binds \
  '[]' \
  --strict-json
```

This prevents the browser sandbox from inheriting the command sandbox's external bind.

Validation showed:

```json
Command sandbox binds:
[
  "/mnt/Dual_Boot_Share/Forge_Shared:/forge-share:rw"
]

Browser-only binds:
[]
```

## Runtime recreation

Existing containers retain their original mounts, so the command and browser sandbox runtimes were removed and allowed to recreate automatically:

```bash
openclaw sandbox recreate \
  --agent main \
  --force

openclaw sandbox recreate \
  --browser \
  --agent main \
  --force

openclaw gateway restart
```

Running the recreate commands a second time reported that no matching runtimes existed. This was harmless because the original containers had already been removed successfully.

## Forge read/write test

A fresh TUI session was used after an older session exceeded the model context window.

Forge ran inside the Docker command sandbox and:

1. Confirmed it was user `sandbox`, UID/GID `1000`.
2. Read `/forge-share/host-created.txt`.
3. Created `/forge-share/forge-created.txt`.
4. Confirmed the entire `/mnt/Dual_Boot_Share` path was hidden.
5. Confirmed `/home/antonio` was hidden.

Observed results:

```text
uid=1000(sandbox) gid=1000(sandbox) groups=1000(sandbox)

Created by Antonio on the Ubuntu host.

Forge successfully wrote to the dedicated shared folder.

PASS_ENTIRE_SHARE_HIDDEN
PASS_HOST_HOME_HIDDEN
```

Ubuntu then confirmed that the Forge-created file reached the host:

```bash
cat /mnt/Dual_Boot_Share/Forge_Shared/forge-created.txt
ls -l /mnt/Dual_Boot_Share/Forge_Shared
```

Observed files:

```text
forge-created.txt
host-created.txt
```

## Actual Docker mount inspection

The running command container was inspected directly.

Observed command-container mounts:

```text
~/.openclaw/sandbox/skills-workspaces/.../skills
  -> /workspace/.openclaw/sandbox-skills/skills (read-only)

~/.openclaw/workspace
  -> /workspace (read/write)

/mnt/Dual_Boot_Share/Forge_Shared
  -> /forge-share (read/write)
```

There was no mount for the entire `/mnt/Dual_Boot_Share` partition.

Observed browser-container mounts:

```text
~/.openclaw/workspace
  -> /workspace (read/write)

~/.openclaw/sandbox/skills-workspaces/.../skills
  -> /workspace/.openclaw/sandbox-skills/skills (read-only)
```

The browser had no `/forge-share`, `Forge_Shared`, or whole-partition mount.

## Direct browser-container denial test

The browser container was tested directly:

```bash
docker exec "$BROWSER_CONTAINER" sh -lc '
test -e /forge-share \
  && echo "FAIL: browser sees Forge_Shared" \
  || echo "PASS: browser cannot see Forge_Shared"

test -e /mnt/Dual_Boot_Share \
  && echo "FAIL: browser sees Dual_Boot_Share" \
  || echo "PASS: browser cannot see Dual_Boot_Share"
'
```

Observed result:

```text
PASS: browser cannot see Forge_Shared
PASS: browser cannot see Dual_Boot_Share
```

The managed browser still opened `https://example.com` successfully after the isolation changes.

## Durable-memory update

The current checkpoint in `~/.openclaw/workspace/MEMORY.md` was updated to record the controlled shared-folder boundary.

The dated note was also updated:

```text
~/.openclaw/workspace/memory/2026-07-28.md
```

The next recorded task is authenticated trusted-LAN access to the OpenClaw Gateway without public exposure.

## Local evidence bundle

A local evidence directory was created:

```text
~/.openclaw/workspace/checkpoints/2026-07-28-controlled-share/
```

Files created:

```text
browser-binds.json
browser-container-mounts.txt
command-binds.json
command-container-mounts.txt
host-verification.txt
partition-mount.txt
```

Review all evidence for secrets, private paths, and unnecessary runtime identifiers before adding selected artifacts to a public repository.

## Security boundary

The approved external data path is exactly:

```text
/mnt/Dual_Boot_Share/Forge_Shared -> /forge-share:rw
```

Rules:

- Do not mount the entire `Dual_Boot_Share` partition into a sandbox.
- Do not mount Ubuntu home directories into the command sandbox.
- Do not add `Forge_Shared` to browser binds.
- Keep secrets, authentication tokens, private keys, and sensitive personal files out of `Forge_Shared`.
- Require deliberate review before adding any other external bind source.
- Treat the external bind as a hole intentionally cut through the sandbox wall. Keep that hole as small as possible.

## Rollback

Remove the command-sandbox bind:

```bash
openclaw config set \
  agents.defaults.sandbox.docker.binds \
  '[]' \
  --strict-json
```

Disable external bind sources when no external binds remain:

```bash
openclaw config set \
  agents.defaults.sandbox.docker.dangerouslyAllowExternalBindSources \
  false \
  --strict-json
```

Validate and recreate the command runtime:

```bash
openclaw config validate

openclaw sandbox recreate \
  --agent main \
  --force

openclaw gateway restart
```

Keep browser binds explicitly empty:

```bash
openclaw config set \
  agents.defaults.sandbox.browser.binds \
  '[]' \
  --strict-json
```

Delete `Forge_Shared` or its test files only after confirming that no needed cross-OS data remains.

## Next task

Inventory the current Ubuntu network, Gateway configuration, listening sockets, and firewall state. Then design authenticated trusted-LAN access while keeping Ollama private, restricting the Gateway with host firewall rules, and avoiding public port forwarding.