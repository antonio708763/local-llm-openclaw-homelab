# Trusted Linux Client Access Through an SSH Tunnel

## Goal

Allow one trusted Linux client to use the OpenClaw Control UI without changing the Gateway from its loopback-only bind and without forwarding any public ports.

The selected design uses an authenticated SSH local-forward tunnel:

```text
Alienware Linux client
  browser -> http://127.0.0.1:18789
                  |
                  | local SSH forward
                  v
Ubuntu Forge host 192.168.110.187:22
                  |
                  v
OpenClaw Gateway 127.0.0.1:18789
                  |
                  v
Ollama 127.0.0.1:11434
```

The OpenClaw Gateway remains unreachable directly from the LAN. The only LAN-facing service used for this path is SSH.

## Validated systems

### Forge host

- Hostname: `antoniosComputer`
- Trusted-LAN address: `192.168.110.187`
- Gateway bind: `127.0.0.1:18789`
- Gateway authentication: token
- SSH service: OpenSSH Server

### Trusted client

- Hostname: `user-Alienware-15-R3`
- Client address during validation: `192.168.110.115`
- Operating system: Ubuntu Linux
- SSH client: OpenSSH 9.6p1

The client address is not required to remain fixed for the SSH tunnel. The Forge host address must remain stable so the client can find it consistently.

## Forge-host preparation

Unused Samba services were disabled because this workstation was not using Samba file sharing:

```bash
sudo systemctl disable --now smbd nmbd
```

OpenSSH Server was installed and enabled:

```bash
sudo apt update
sudo apt install -y openssh-server
sudo systemctl enable --now ssh
```

Validation:

```bash
sudo sshd -t
systemctl is-enabled ssh
systemctl is-active ssh
sudo ss -lntup | grep -E ':(22)\b'
```

Validated result:

```text
SSH configuration: valid
ssh service: enabled and active
TCP port 22: listening
```

## Dedicated client key

A dedicated Ed25519 key was created on the trusted Linux client:

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh

ssh-keygen \
  -t ed25519 \
  -a 100 \
  -f ~/.ssh/openclaw_forge \
  -C "OpenClaw Forge trusted Linux client"
```

The public key was installed for the `antonio` account on the Forge host:

```bash
ssh-copy-id \
  -i ~/.ssh/openclaw_forge.pub \
  antonio@192.168.110.187
```

Key-only connection test:

```bash
ssh \
  -i ~/.ssh/openclaw_forge \
  -o IdentitiesOnly=yes \
  antonio@192.168.110.187
```

The private key remains only on the trusted client and is never committed to Git.

## Client SSH profile

The trusted client uses this entry in `~/.ssh/config`:

```sshconfig
Host forge-gateway
    HostName 192.168.110.187
    User antonio
    IdentityFile ~/.ssh/openclaw_forge
    IdentitiesOnly yes
    LocalForward 18789 127.0.0.1:18789
    ExitOnForwardFailure yes
    ServerAliveInterval 30
    ServerAliveCountMax 3
```

Permissions:

```bash
chmod 600 ~/.ssh/config
```

Configuration inspection:

```bash
ssh -G forge-gateway | grep -E \
'^(hostname|user|identityfile|localforward|exitonforwardfailure|serveraliveinterval)'
```

## Manual tunnel test

Start the tunnel in the foreground:

```bash
ssh -N forge-gateway
```

In a second client terminal:

```bash
ss -ltnp | grep ':18789'
curl -I --max-time 10 http://127.0.0.1:18789/
```

Expected results:

```text
127.0.0.1:18789 is owned by ssh
HTTP/1.1 200 OK
```

Open the dashboard on the trusted client:

```text
http://127.0.0.1:18789/
```

The Gateway token is still required. The token is entered locally in the Control UI and is not stored in this repository.

## Removing the conflicting local client Gateway

The Alienware already had its own older OpenClaw Gateway using local port `18789`. It was stopped and disabled so that the SSH tunnel could own the client-side loopback port:

```bash
openclaw gateway stop --disable
systemctl --user disable openclaw-gateway.service
```

Validation:

```bash
systemctl --user is-active openclaw-gateway.service || true
systemctl --user is-enabled openclaw-gateway.service || true
ss -ltnp | grep ':18789' \
  || echo "PASS: local port 18789 is available"
```

Validated result:

```text
local OpenClaw Gateway: inactive and disabled
client port 18789: available before tunnel startup
```

## Persistent systemd user tunnel

The client unit is stored at:

```text
~/.config/systemd/user/forge-gateway-tunnel.service
```

Unit contents:

```ini
[Unit]
Description=Persistent SSH tunnel to Forge OpenClaw Gateway
After=network-online.target
Wants=network-online.target
StartLimitIntervalSec=0

[Service]
Type=simple
ExecStart=/usr/bin/ssh -N -T -o BatchMode=yes forge-gateway
Restart=always
RestartSec=10

[Install]
WantedBy=default.target
```

Enable and start it:

```bash
systemctl --user daemon-reload
systemctl --user enable --now forge-gateway-tunnel.service
```

Allow the user service manager to run without an interactive login:

```bash
sudo loginctl enable-linger "$USER"
loginctl show-user "$USER" --property=Linger
```

Expected result:

```text
Linger=yes
```

## Reboot validation

After rebooting the trusted Linux client, the following checks passed:

```bash
systemctl --user is-enabled forge-gateway-tunnel.service
systemctl --user is-active forge-gateway-tunnel.service
systemctl --user --no-pager --full status forge-gateway-tunnel.service
ss -ltnp | grep ':18789'
curl -I --max-time 10 http://127.0.0.1:18789/
```

Validated result:

```text
Tunnel unit: enabled
Tunnel runtime: active
Listener owner: ssh
Local listener: 127.0.0.1:18789 and [::1]:18789
Remote dashboard response: HTTP/1.1 200 OK
```

The Control UI loaded after reboot, accepted the Forge Gateway token, and successfully opened the existing Forge chat and durable memory content.

## Security properties

- The OpenClaw Gateway remains bound only to `127.0.0.1` on the Forge host.
- The Gateway port is not exposed directly to the trusted LAN.
- No router port-forward is configured.
- The tunnel is encrypted and authenticated with a dedicated SSH key.
- The forwarded client socket is also loopback-only.
- OpenClaw token authentication remains enabled as a second authentication layer.
- The trusted client does not need Ollama, SearXNG, or the model port exposed to it.
- The client key grants SSH access to the `antonio` account, so SSH hardening is the next security priority.

## Remaining hardening

The first trusted-client milestone is complete, but Phase 7 is not fully complete until these items are addressed:

1. Disable SSH password authentication after confirming emergency key access.
2. Consider a dedicated restricted account for tunnel-only use instead of the administrator account.
3. Restrict SSH ingress with UFW and OPNsense to the trusted LAN or approved client addresses.
4. Confirm Guest and IoT VLANs cannot reach TCP port 22 on the Forge host.
5. Test automatic tunnel recovery after Wi-Fi loss and Forge-host restart.
6. Decide whether the local client should use a different port if its own OpenClaw Gateway is restored later.
7. Audit NetBird before enabling encrypted access from outside the home LAN.

## Useful operations

Status:

```bash
systemctl --user status forge-gateway-tunnel.service
```

Restart:

```bash
systemctl --user restart forge-gateway-tunnel.service
```

Logs:

```bash
journalctl --user -u forge-gateway-tunnel.service -n 100 --no-pager
```

Stop temporarily:

```bash
systemctl --user stop forge-gateway-tunnel.service
```

Disable permanently:

```bash
systemctl --user disable --now forge-gateway-tunnel.service
```

Remove the unit:

```bash
rm ~/.config/systemd/user/forge-gateway-tunnel.service
systemctl --user daemon-reload
```

Remove the client key from the Forge host only after identifying its exact line in:

```text
~/.ssh/authorized_keys
```

Do not delete unrelated authorized keys.