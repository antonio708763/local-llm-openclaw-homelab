# Ollama and Model Validation

## Installation

Ollama was installed on Ubuntu using the official Linux installation script:

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

The installer:

- Installed Ollama under `/usr/local`
- Created the `ollama` service account
- Added the required video and render group access
- Added the current user to the `ollama` group
- Created and enabled the systemd service
- Detected the NVIDIA GPU

## Service validation

Commands:

```bash
ollama --version
systemctl is-active ollama
systemctl status ollama --no-pager
```

Observed result:

```text
Ollama version: 0.32.3
Service state:  active (running)
Startup state:  enabled
GPU detection:  NVIDIA GPU installed
```

## Model download

```bash
ollama pull qwen3-coder:30b
```

The model downloaded successfully and its manifest was written without errors.

## Functional test

The model was started with:

```bash
ollama run qwen3-coder:30b
```

Test prompt:

```text
Write a short Python function that checks whether a TCP port is open.
```

The model returned a usable Python function based on `socket.connect_ex()` and included example usage.

## GPU-residency test

While the model was generating, a second terminal ran:

```bash
ollama ps
nvidia-smi
```

Observed result:

```text
Model:             qwen3-coder:30b
Ollama model size: 21 GB while loaded
Processor:         100% GPU
Context:           32768 tokens
VRAM usage:        21733 MiB / 24564 MiB
Model process:     approximately 21174 MiB
GPU utilization:   90%
Temperature:       47 C
Power:             267 W / 450 W
```

## Conclusion

The quantized `qwen3-coder:30b` model fits entirely within the RTX 4090's VRAM at the tested 32,768-token context allocation. No CPU or system-RAM offloading was reported by `ollama ps`.

This validates the main workstation for the next phase: connecting OpenClaw to Ollama's native local endpoint.

## OpenClaw endpoint planned for the next phase

```text
http://127.0.0.1:11434
```

Ollama should remain bound locally at first. OpenClaw will become the authenticated and policy-controlled access layer for future LAN and remote access.
