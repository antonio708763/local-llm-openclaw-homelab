# Validation Checklists

## Windows post-resize

- [ ] Windows boots normally
- [ ] `chkdsk C: /scan` reports no problems
- [ ] Event Viewer shows no recurring disk or NTFS errors
- [ ] Important files open from Desktop, Documents, Downloads, Pictures, and Videos
- [ ] Important applications launch
- [ ] Archive drives are visible
- [ ] `Dual_Boot_Share` appears as `H:`
- [ ] Files can be created and read on `H:`

## Ubuntu post-resize

- [x] Ubuntu boots normally
- [x] `Dual_Boot_Share` appears in Files
- [ ] Record the partition UUID
- [ ] Configure a stable mount point
- [ ] Confirm read and write access
- [ ] Confirm cross-OS file compatibility

## Backup validation

- [ ] Open several backed-up files from `SSD_Archive(1)`
- [ ] Review the Robocopy log
- [ ] Confirm no Robocopy exit code of 8 or higher
- [ ] Keep the backup until the system is stable

## Local LLM readiness

- [ ] NVIDIA driver working
- [ ] RTX 4090 visible
- [ ] Sufficient free model storage
- [ ] Stable LAN address
- [ ] Shared workspace mounted
- [ ] OpenClaw access boundaries documented
