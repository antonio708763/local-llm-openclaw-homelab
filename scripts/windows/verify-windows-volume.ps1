#requires -RunAsAdministrator
$ErrorActionPreference = "Stop"

Write-Host "=== Volume inventory ==="
Get-Volume |
    Sort-Object DriveLetter |
    Format-Table DriveLetter, FileSystemLabel, FileSystem, HealthStatus, Size, SizeRemaining -AutoSize

Write-Host "`n=== Physical disks ==="
Get-PhysicalDisk |
    Format-Table FriendlyName, MediaType, HealthStatus, OperationalStatus, Size -AutoSize

Write-Host "`n=== Read-only NTFS scan of C: ==="
chkdsk C: /scan
$chkdskExit = $LASTEXITCODE

Write-Host "`nCHKDSK exit code: $chkdskExit"
if ($chkdskExit -eq 0) {
    Write-Host "No filesystem problems were reported."
} else {
    Write-Warning "Review the CHKDSK output before making additional storage changes."
}
