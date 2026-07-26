# OpenClaw sandbox image

Build from the repository root:

```bash
docker build -t openclaw-sandbox:bookworm-slim \
  -f docker/openclaw-sandbox/Dockerfile .
```

The image is based on Debian Bookworm Slim, installs a small set of coding and troubleshooting utilities, creates an unprivileged `sandbox` account, and remains running with `sleep infinity` when OpenClaw starts a sandbox runtime.
