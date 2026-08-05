# SSH Key-Only Hardening for the Forge Host

## Goal

Harden the LAN-facing OpenSSH service on the Forge host after validating that the trusted Alienware client has a working dedicated recovery key.

The OpenClaw Gateway remains bound to `127.0.0.1:18789`. SSH is the only LAN-facing service used to transport the trusted client's local-forward tunnel.

## Validated systems

### Forge host

- Hostname: `antoniosComputer`
- Account used during this milestone: `antonio`
- Trusted-LAN address: `192.168.110.187`
- OpenSSH service: enabled and active
- OpenClaw Gateway: loopback-only on `127.0.0.1:18789`

### Trusted client

- Hostname: `user-Alienware-15-R3`
- Address during validation: `192.168.110.115`
- Dedicated key: `~/.ssh/openclaw_forge`
- Persistent tunnel unit: `forge-gateway-tunnel.service`

The private key and its full public-key line are not stored in this repository.

## Pre-flight recovery test

Before changing the server policy, the Alienware client explicitly tested the dedicated key with password and keyboard-interactive fallback disabled:

```bash
ssh \
  -i ~/.ssh/openclaw_forge \
  -o IdentitiesOnly=yes \
  -o PreferredAuthentications=publickey \
  -o PasswordAuthentication=no \
  -o KbdInteractiveAuthentication=no \
  -o ConnectTimeout=10 \
  antonio@192.168.110.187 \
  'echo "PASS: emergency key-only SSH access works"; hostname; whoami; id'
```

Validated result:

```text
PASS: emergency key-only SSH access works
Host: antoniosComputer
User: antonio
```

The Forge host also confirmed that `~/.ssh/authorized_keys` contains the dedicated key identified by the comment:

```text
OpenClaw Forge trusted Linux client
```

## Root-only backup

A root-owned backup of the OpenSSH configuration was created before hardening:

```text
/root/openssh-before-key-only-20260805-003631.tar.gz
```

The archive is not committed to Git because it is a host recovery artifact.

## Hardening configuration

The following drop-in was created:

```text
/etc/ssh/sshd_config.d/00-openclaw-key-only.conf
```

Contents:

```sshconfig
# OpenClaw Forge SSH authentication hardening
#
# Require public-key authentication for normal SSH access.
# Keep UsePAM unchanged for Ubuntu account and session handling.

PubkeyAuthentication yes
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitEmptyPasswords no
```

The configuration was validated before reload:

```bash
sudo sshd -t
```

Validated result:

```text
PASS: sshd configuration syntax is valid.
```

The SSH service was reloaded without rebooting:

```bash
sudo systemctl reload ssh
```

Validated result:

```text
SSH service: enabled and active
TCP port 22: listening on IPv4 and IPv6
```

## Effective policy

The effective policy for the Alienware-to-Forge connection reports:

```text
UsePAM yes
PermitRootLogin without-password
PubkeyAuthentication yes
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitEmptyPasswords no
```

`PermitRootLogin without-password` is Ubuntu's existing policy. Root password login is not allowed, but root key login is still theoretically permitted. Changing this to `PermitRootLogin no` is a later hardening refinement after the normal recovery and maintenance path is fully documented.

## Negative authentication test

The client deliberately attempted a connection without offering a public key while requesting password and keyboard-interactive methods.

The server reported:

```text
Authentications that can continue: publickey
Permission denied (publickey).
```

This is the expected successful result. It proves that the server does not offer password or keyboard-interactive fallback.

## Post-hardening tunnel validation

The dedicated key connected successfully after hardening:

```text
PASS: new key-only connection works after hardening
Host: antoniosComputer
User: antonio
```

The persistent tunnel was then restarted. Its PID changed from `13456` to `27898`, confirming that a new SSH process established a fresh connection under the hardened policy.

Validated result:

```text
Tunnel unit: enabled
Tunnel runtime: active/running
Client listener: 127.0.0.1:18789 and [::1]:18789, owned by ssh
Remote dashboard response: HTTP/1.1 200 OK
PASS: Persistent key-only OpenClaw tunnel works after SSH hardening.
```

## Security result

Completed:

- Dedicated emergency key access validated before policy changes.
- Public-key authentication enabled.
- SSH password authentication disabled.
- Keyboard-interactive authentication disabled.
- Empty-password authentication disabled.
- Configuration syntax validated before reload.
- Root-only rollback backup created.
- New interactive key-only connection validated after reload.
- Persistent OpenClaw tunnel restarted and validated under the hardened policy.
- Gateway token authentication remains required after the SSH tunnel is established.

Remaining exposure:

- The tunnel currently authenticates as the normal `antonio` administrator account.
- SSH still listens on the Forge host's LAN interfaces.
- UFW and OPNsense ingress restrictions have not yet been applied.
- Guest and IoT VLAN denial tests have not yet been performed.
- Root key login remains permitted by the inherited `PermitRootLogin without-password` policy.

## Rollback

The safest rollback is to use local console access on the Forge host.

Remove the hardening drop-in, validate, and reload:

```bash
sudo rm -f /etc/ssh/sshd_config.d/00-openclaw-key-only.conf
sudo sshd -t
sudo systemctl reload ssh
```

The root-only archive can also restore the previous OpenSSH configuration if a broader rollback is required.

Never remove the hardening file remotely unless another tested session or local console path is available.

## Next task

Evaluate and build a dedicated restricted account for tunnel-only access. The target account should not have sudo access or a normal administrative role and should be constrained to the OpenClaw local-forward use case before UFW and OPNsense rules are tightened.
