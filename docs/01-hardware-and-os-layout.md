# Hardware and OS Layout

| Component | Configuration |
|---|---|
| GPU | NVIDIA RTX 4090, 24 GB VRAM |
| CPU | AMD Ryzen 9 7950X |
| RAM | 64 GB DDR5 |
| Primary AI OS | Ubuntu |
| Secondary OS | Windows 10 |
| Boot method | Dual boot |
| Model | `qwen3-coder:30b` |
| Runtime | Ollama |
| Agent | OpenClaw |

## Storage design

```text
Ubuntu NVMe
└── Ubuntu ext4 root

Windows NVMe
├── EFI partition
├── Microsoft Reserved partition
├── Windows NTFS system partition
└── Dual_Boot_Share NTFS partition

Additional storage
├── SSD_Archive(1) — NTFS
└── HDD_Archive — NTFS
```

## Drive-identification warning

Linux NVMe names can change between boots. Identify drives by capacity, labels, filesystems, UUIDs, and partition layout, not only by names such as `/dev/nvme1n1`.
