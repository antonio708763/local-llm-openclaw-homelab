# Docker and OpenClaw Sandbox

## Goal

Run Forge's command-line tools inside a Docker container instead of directly on the Ubuntu host. This reduces the blast radius of generated commands while preserving controlled Internet access and read/write access to the OpenClaw workspace.

## Docker installation

Docker Engine was installed from Docker's official Ubuntu repository rather than Snap.

Validated versions:

```text
Docker Engine:  29.6.2
Docker Compose: v5.3.1
Service state:  active
```

Validation commands:

```bash
sudo systemctl enable --now docker
sudo docker run --rm hello-world
docker --version
docker compose version
systemctl is-active docker
```

The `hello-world` test completed successfully. The Ubuntu user was added to the `docker` group, followed by a reboot. After reboot, `docker ps` worked without `sudo`.

> The Docker group effectively grants host-level Docker control. Membership should be limited to trusted administrators.

## Post-reboot service validation

After reboot:

```bash
docker ps
systemctl is-active docker
systemctl is-active ollama
openclaw gateway status --require-rpc
```

Observed:

- Docker active
- Ollama active
- OpenClaw Gateway enabled and running
- Gateway RPC read probe `ok`
- Gateway still bound to loopback at `127.0.0.1:18789`
- No containers running yet, which was expected

## Sandbox image

The custom image is stored in this repository at:

```text
docker/openclaw-sandbox/Dockerfile
```

Build command:

```bash
docker build -t openclaw-sandbox:bookworm-slim \
  -f docker/openclaw-sandbox/Dockerfile .
```

The original build used a heredoc and produced:

```text
Image: openclaw-sandbox:bookworm-slim
Size on disk: approximately 309 MB
Content size: approximately 76.6 MB
```

Included tools:

- Bash
- CA certificates
- curl
- Git
- jq
- Python 3
- ripgrep

The container runs as the unprivileged `sandbox` user.

## OpenClaw sandbox configuration

Applied settings:

```bash
openclaw config set agents.defaults.sandbox.mode '"all"' --strict-json
openclaw config set agents.defaults.sandbox.backend '"docker"' --strict-json
openclaw config set agents.defaults.sandbox.scope '"agent"' --strict-json
openclaw config set agents.defaults.sandbox.workspaceAccess '"rw"' --strict-json
openclaw config set agents.defaults.sandbox.docker.image '"openclaw-sandbox:bookworm-slim"' --strict-json
openclaw config set agents.defaults.sandbox.docker.network '"bridge"' --strict-json
openclaw config validate
openclaw gateway restart
```

Meaning:

- `mode=all`: sandbox all agent sessions
- `backend=docker`: use Docker containers
- `scope=agent`: one sandbox scope for the agent
- `workspaceAccess=rw`: mount the OpenClaw workspace read/write
- custom image: use the locally built image
- `network=bridge`: allow outbound networking from the container

## Effective policy

Inspection command:

```bash
openclaw sandbox explain --session agent:main:main
```

Confirmed:

```text
runtime: sandboxed
mode: all
scope: agent
workspace access: rw
host workspace: /home/antonio/.openclaw/workspace
container workspace: /workspace
backend: docker
network: bridge
```

The sandbox currently exposes only the OpenClaw workspace. `Dual_Boot_Share` and the rest of the Ubuntu filesystem are not mounted into it.

The default sandbox tool policy permits core file and process tools, while browser, node, gateway, messaging, and other integration tools remain denied until explicitly configured.

## Current checkpoint

```bash
openclaw sandbox list
```

returned:

```text
No sandbox runtimes found.
Total: 0 (0 running)
```

This is expected. The configuration is active, but OpenClaw has not yet executed the first tool request that would instantiate the container.

## Next validation

1. Ask Forge to run a harmless read-only command.
2. Approve it through the cautious execution policy.
3. Confirm a sandbox container appears.
4. Verify the command sees the container environment, not the Ubuntu host.
5. Verify outbound Internet access from inside the sandbox.
6. Review browser and web-search configuration separately.
7. Run `openclaw security audit --deep` again.

Do not grant access to `Dual_Boot_Share`, production systems, or elevated host commands until these tests pass.
