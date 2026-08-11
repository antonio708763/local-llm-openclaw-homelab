# Alienware Power Node

## Purpose

The Ubuntu Alienware laptop is the first remote computer attached to the `Power` OpenClaw profile as an OpenClaw node host. The RTX 4090 workstation continues to run the LLM and Power Gateway. The Alienware node supplies remote system tools so the Power agent can perform work on that laptop.

This is separate from simply opening the Power dashboard remotely. The SSH tunnel provides access to the dashboard; the OpenClaw node process provides remote-computer capabilities.

## Transport layout

```text
Alienware Ubuntu client
    |
    | SSH local forward
    | client 127.0.0.1:19789
    |        -> RTX host 127.0.0.1:19789
    v
Power Gateway on RTX workstation
    |
    | OpenClaw node WebSocket
    v
Alienware node host
```

The existing dedicated SSH key is:

```text
~/.ssh/openclaw_forge
```

The Forge dashboard tunnel remains on port `18789`. Power uses a second local-forward tunnel on port `19789`.

The Power tunnel service created on the Alienware is:

```text
power-gateway-tunnel.service
```

## Matching OpenClaw version

The Alienware originally had an older OpenClaw build. It was upgraded to match the RTX workstation:

```text
OpenClaw 2026.7.1-2
```

This version exposes the `openclaw node` command family used for the node host.

## Node state

The isolated node state directory is:

```text
~/.openclaw-power-node
```

The node display name is:

```text
Alienware-15-R3
```

A successful foreground connection uses the Power Gateway token in the environment and the SSH-forwarded loopback port:

```bash
OPENCLAW_GATEWAY_TOKEN="$POWER_TOKEN" \
OPENCLAW_STATE_DIR="$HOME/.openclaw-power-node" \
openclaw node run \
  --host 127.0.0.1 \
  --port 19789 \
  --display-name "Alienware-15-R3"
```

Expected connection message:

```text
node host gateway connected: ws://127.0.0.1:19789
```

Do not commit the real Gateway token to Git.

## Important CLI facts discovered during troubleshooting

### `--no-tls` is not a valid option

For OpenClaw `2026.7.1-2`, `openclaw node run --help` shows:

```text
--host <host>
--port <port>
--display-name <name>
--node-id <id>
--tls
--tls-fingerprint <sha256>
--context-path <path>
```

For the local SSH-forwarded `ws://127.0.0.1:19789` connection, omit `--tls`. The `--tls` flag enables TLS; there is no `--no-tls` flag.

### The Gateway token must be present in the node process environment

Running the node without the token produced:

```text
unauthorized: gateway token missing
AUTH_TOKEN_MISSING
```

The fix was to launch the node with:

```bash
OPENCLAW_GATEWAY_TOKEN="$POWER_TOKEN"
```

The browser choosing "Never" when Brave asked whether to save a login token does not control the CLI node process. The node needs its own environment variable or service environment.

### `devices list` is not the node list

This was a major source of confusion.

```bash
openclaw --profile power devices list
```

showed three `operator` devices. Those entries were Control UI/TUI/operator authentication devices, not the Alienware node host.

For remote node hosts use:

```bash
openclaw --profile power nodes status
openclaw --profile power nodes status --json
openclaw --profile power nodes pending
openclaw --profile power nodes describe --node Alienware-15-R3
```

### `system.which` requires `bins`

An early invoke attempt used a single-name parameter and failed with:

```text
INVALID_REQUEST: bins required
```

In this OpenClaw build the correct shape is an array:

```bash
openclaw --profile power nodes invoke \
  --node Alienware-15-R3 \
  --command system.which \
  --params '{"bins":["hostname","whoami","bash"]}'
```

The successful result resolved:

```text
hostname -> /usr/bin/hostname
whoami   -> /usr/bin/whoami
bash     -> /usr/bin/bash
```

This is now the preferred preflight when verifying which executable paths the node can see.

## The stale-pairing problem

The most confusing failure looked healthy at first:

```text
paired: true
connected: true
approvalState: unapproved
caps: []
commands: []
pendingRequestId: none
```

The Alienware node was physically connected to the Gateway but its old pairing had an empty effective command set. There was no usable pending approval request, so repeatedly checking `nodes pending` or changing exec settings could not fix it.

### Reliable recovery procedure

If this exact state returns, do not keep changing random policy settings. Refresh the node pairing itself.

1. Stop the Alienware node process.
2. Remove the stale Alienware node entry from the Power Gateway.
3. Start the Alienware node again with the correct Gateway token and isolated state directory.
4. Immediately check for a new pending request.
5. Approve that new request.
6. Verify the node advertises capabilities and commands before changing exec policy.

Gateway-side commands:

```bash
openclaw --profile power nodes status --json
openclaw --profile power nodes remove --node Alienware-15-R3
openclaw --profile power nodes pending
```

After restarting the node, a fresh pending entry should appear:

```text
Pending
Request                                  Node
<new-request-id>                         Alienware-15-R3
```

Approve the exact fresh request:

```bash
openclaw --profile power nodes approve <new-request-id>
```

Then verify:

```bash
openclaw --profile power nodes describe --node Alienware-15-R3
openclaw --profile power nodes status --json
```

The successful result showed:

```text
Status:       paired · connected
Approval:     approved
Caps:         browser, file, local-inference, system
```

Advertised commands included:

```text
browser.proxy
ollama.chat
ollama.models
system.execApprovals.get
system.execApprovals.set
system.run
system.run.prepare
system.which
```

This stale-pairing recovery is the procedure to use first if the Alienware node later disappears or reconnects with empty capabilities.

## Node-side exec approvals

The node approvals snapshot is stored on the Alienware under the isolated node state:

```text
~/.openclaw-power-node/exec-approvals.json
```

A file-based update was used because an earlier `--stdin` attempt produced a JSON5 end-of-input parsing error.

Create a temporary policy file on the RTX host:

```bash
cat > /tmp/alienware-exec-approvals.json <<'EOF'
{
  "version": 1,
  "defaults": {
    "security": "full",
    "ask": "off",
    "askFallback": "full"
  }
}
EOF
```

Apply it to the node:

```bash
openclaw --profile power approvals set \
  --node Alienware-15-R3 \
  --file /tmp/alienware-exec-approvals.json
```

Verify:

```bash
openclaw --profile power approvals get \
  --node Alienware-15-R3
```

Validated node-side defaults:

```text
security=full
ask=off
askFallback=full
```

## Power exec target

The Power Gateway is currently configured to send exec work to the Alienware node:

```bash
openclaw --profile power config set tools.exec.host node
openclaw --profile power config unset tools.exec.security
openclaw --profile power config unset tools.exec.ask
openclaw --profile power config set tools.exec.mode full
openclaw --profile power config set tools.exec.node Alienware-15-R3
openclaw --profile power config validate
```

Current expected config:

```json
{
  "host": "node",
  "mode": "full",
  "node": "Alienware-15-R3"
}
```

The legacy `tools.exec.security` and `tools.exec.ask` fields must not be combined with `tools.exec.mode`. OpenClaw rejected that mixed schema during setup.

## Execution validation status

The node-pairing and capability layers are solved. The node advertises `system.run`, `system.run.prepare`, and `system.which`, and `system.which` successfully resolves ordinary executable paths when called with the correct `bins` parameter.

Earlier browser tests produced mixed execution results:

```text
hostname -> SYSTEM_RUN_DENIED: approval required
whoami   -> SYSTEM_RUN_DENIED: approval required
pwd      -> succeeded and returned /home/user
```

Because the node pairing is now healthy, do not tear it down to troubleshoot execution policy. The next validation should focus only on the remaining command approval/run path and should use repeated harmless commands before declaring remote execution fully finished.

## Fast diagnostic checklist

When the Alienware node is not working, check in this order:

```bash
# On the Alienware
curl -fsSI --max-time 10 http://127.0.0.1:19789/ | head -n 1

# On the RTX workstation
openclaw --profile power nodes status
openclaw --profile power nodes pending
openclaw --profile power nodes describe --node Alienware-15-R3
openclaw --profile power approvals get --node Alienware-15-R3
openclaw --profile power config get tools.exec
```

Interpretation:

```text
No HTTP 200 on Alienware port 19789
    -> fix the SSH Power tunnel first.

Node missing from nodes status
    -> restart the node process/service.

Connected but unapproved with caps=[] and commands=[]
    -> remove stale node pairing, reconnect, approve fresh request.

Approved with caps and commands present
    -> pairing is healthy; troubleshoot exec policy, not pairing.

AUTH_TOKEN_MISSING
    -> node process was started without OPENCLAW_GATEWAY_TOKEN.

INVALID_REQUEST: bins required
    -> system.which was called with the wrong parameter shape; use a bins array.
```

## Current checkpoint

As of August 11, 2026, the Alienware node is a real OpenClaw node host, separate from the operator devices in `devices list`, and it is paired, connected, approved, and advertising system commands.

The key lesson is to distinguish three layers before changing configuration:

```text
1. SSH tunnel connectivity
2. OpenClaw node pairing/capability approval
3. Exec-command approval/run policy
```

Troubleshoot them in that order. Changing layer 3 cannot repair a broken or stale layer-2 pairing.

The next project-wide priority is Power Tool Search/context reduction. Final repeated harmless Alienware exec validation remains on the queue after that usability work.
