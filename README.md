# Local LLM + OpenClaw Homelab

A documented build for running a local coding model on a dual-boot workstation and making it available to trusted LAN and remote devices.

## Target system

- **Model:** `qwen3-coder:30b`
- **Model runtime:** Ollama `0.32.3`
- **Agent/orchestration layer:** OpenClaw
- **Primary host OS:** Ubuntu
- **Secondary OS:** Windows 10
- **GPU:** NVIDIA RTX 4090, 24 GB VRAM
- **CPU:** AMD Ryzen 9 7950X
- **Memory:** 64 GB DDR5
- **Storage:** Separate NVMe drives for Windows and Ubuntu
- **Shared storage:** `Dual_Boot_Share`, NTFS, mounted at `/mnt/Dual_Boot_Share`
- **Remote-access goal:** LAN access plus encrypted remote access
- **Likely remote networking:** Existing self-hosted NetBird deployment, pending audit

## Current project status

### Completed

- [x] Kept Windows and Ubuntu on separate NVMe drives
- [x] Disabled Windows Fast Startup and hibernation
- [x] Confirmed BitLocker is not enabled
- [x] Backed up important Windows data to `SSD_Archive(1)`
- [x] Repaired and verified the Windows NTFS filesystem
- [x] Resized the Windows NTFS partition using GParted
- [x] Created an approximately 500 GB NTFS shared partition
- [x] Named the shared partition `Dual_Boot_Share`
- [x] Verified Windows data integrity after the resize
- [x] Configured and tested the Ubuntu mount at `/mnt/Dual_Boot_Share`
- [x] Recorded the shared-partition UUID as `48003BD2003BC62A`
- [x] Verified the NVIDIA driver and CUDA access
- [x] Installed and enabled Ollama `0.32.3`
- [x] Downloaded and tested `qwen3-coder:30b`
- [x] Confirmed the model runs with `100% GPU` residency
- [x] Confirmed a 32,768-token context allocation

### Next phases

- [ ] Confirm the shared partition mounts automatically after a reboot
- [ ] Install and configure OpenClaw
- [ ] Connect OpenClaw to Ollama at `http://127.0.0.1:11434`
- [ ] Keep Ollama bound locally rather than exposing it directly
- [ ] Audit the existing NetBird deployment
- [ ] Enable authenticated LAN access
- [ ] Enable authenticated remote access
- [ ] Add tightly scoped OpenClaw node access to lab systems
- [ ] Keep production systems read-only until the workflow is proven

## Validated model result

During generation:

```text
Model:           qwen3-coder:30b
Processor:       100% GPU
Context:         32768 tokens
GPU memory:      approximately 21.7 GiB used of 24.6 GiB
GPU utilization: 90%
GPU temperature: 47 C
```

This confirms that the selected quantized model fits entirely on the RTX 4090 without CPU or system-RAM offloading at the tested context allocation.

## Repository map

```text
.
├── README.md
├── CHANGELOG.md
├── .gitignore
├── docs
│   ├── 00-project-overview.md
│   ├── 01-hardware-and-os-layout.md
│   ├── 02-storage-layout.md
│   ├── 03-shared-partition-build-log.md
│   ├── 04-backup-and-recovery.md
│   ├── 05-network-access-plan.md
│   ├── 06-security-model.md
│   ├── 07-implementation-roadmap.md
│   ├── 08-validation-checklists.md
│   ├── 09-troubleshooting-log.md
│   └── 10-ollama-and-model-validation.md
├── scripts
│   ├── ubuntu
│   │   ├── inventory-host.sh
│   │   └── verify-shared-partition.sh
│   └── windows
│       ├── backup-user-profile.ps1
│       └── verify-windows-volume.ps1
└── assets
    └── screenshots
        ├── README.md
        ├── dual-boot-share-mounted.webp
        ├── permanent-ntfs-mount-test.webp
        ├── ollama-installation.webp
        ├── qwen3-coder-pull-complete.webp
        ├── qwen3-coder-gpu-validation.webp
        └── qwen3-coder-first-response.webp
```

## Safety rules

1. Back up important files before changing partitions, bootloaders, model runtimes, or agent permissions.
2. Identify drives by **size, filesystem, label, and partition layout**, not only by `/dev/nvmeXnY`; Linux device numbers can change between boots.
3. Do not expose Ollama directly to the public Internet.
4. Require authentication for OpenClaw LAN and remote access.
5. Start with read-only or approval-required actions.
6. Test infrastructure changes against lab systems before production.
7. Keep scripts, configuration files, and change history in Git.
