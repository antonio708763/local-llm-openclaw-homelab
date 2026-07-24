# Backup and Recovery

## Backup destination

`SSD_Archive(1)` was used as the backup drive before resizing the Windows partition.

## User-profile backup

```powershell
New-Item -ItemType Directory -Path "E:\Before-C-Resize-Backup" -Force

robocopy "C:\Users\User" `
  "E:\Before-C-Resize-Backup\User-Files" `
  /E /XJ /COPY:DAT /DCOPY:DAT /R:1 /W:1 /MT:16 `
  /LOG:"E:\Before-C-Resize-Backup\robocopy.log"
```

Robocopy exit codes `0–7` are successful or nonfatal. Exit code `8` or higher indicates at least one copy failure.

## Keep the backup until

- Windows has booted normally several times.
- `chkdsk C: /scan` reports no problems.
- Important files and applications open normally.
- `Dual_Boot_Share` works in both operating systems.
- A normal ongoing backup is established.
