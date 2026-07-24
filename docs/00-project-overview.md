# Project Overview

## Objective

Build a local AI workstation that can:

- Run `qwen3-coder:30b` on an RTX 4090.
- Use OpenClaw as the agent and tool-execution layer.
- Generate Bash, PowerShell, Python, Docker, Ansible, Terraform, and general application code.
- Support trusted LAN access and encrypted remote access.
- Interact with selected homelab systems using approval-controlled tools.
- Keep prompts, code, and model execution local whenever practical.

## Design priorities

- Local-first and privacy-first
- Repeatable and documented
- Recoverable
- Least privilege
- Lab before production
- No direct public exposure of Ollama

## Architecture

```text
Trusted LAN or remote client
            |
      OpenClaw Gateway
            |
           Ollama
            |
    qwen3-coder:30b
            |
 Approved tools, nodes, SSH, APIs
            |
 Windows, Linux, Proxmox, Docker, and lab systems
```

## Availability limitation

The workstation is dual booted. Ollama and OpenClaw are available only while Ubuntu is running. The current plan is to leave Ubuntu running most of the time and reconsider a dedicated always-on AI host later.
