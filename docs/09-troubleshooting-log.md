# Troubleshooting Log

## Shared partition could not expand

The original unallocated space was before `Dual_Boot_Share`. Windows Disk Management only extends into adjacent unallocated space on the right.

## Windows C: showed 0 MB available to shrink

Investigated page file, crash dumps, hibernation, Fast Startup, NTFS errors, and fragmented free space.

```powershell
chkdsk C: /scan
chkdsk C: /spotfix
chkdsk C: /scan
defrag C: /X /U /V
```

The filesystem became clean, but unmovable NTFS metadata still blocked Disk Management. The unmounted partition was resized successfully with GParted.

## GParted initially showed the wrong NVMe

Multiple drives had similar capacities and Linux NVMe numbering changed between boots. The Windows drive was identified using its EFI, Microsoft Reserved, and large NTFS partition layout.

## Robocopy could not open its log

The log's parent directory did not exist. It was created first:

```powershell
New-Item -ItemType Directory -Path "E:\Before-C-Resize-Backup" -Force
```
