param(
    [Parameter(Mandatory = $true)]
    [ValidateScript({ Test-Path $_ -PathType Container })]
    [string]$SourceProfile,

    [Parameter(Mandatory = $true)]
    [string]$DestinationRoot
)

$ErrorActionPreference = "Stop"
New-Item -ItemType Directory -Path $DestinationRoot -Force | Out-Null

$destination = Join-Path $DestinationRoot "User-Files"
$logPath = Join-Path $DestinationRoot "robocopy.log"

$arguments = @(
    $SourceProfile,
    $destination,
    "/E",
    "/XJ",
    "/COPY:DAT",
    "/DCOPY:DAT",
    "/R:1",
    "/W:1",
    "/MT:16",
    "/LOG:$logPath"
)

& robocopy @arguments
$exitCode = $LASTEXITCODE

Write-Host "Robocopy exit code: $exitCode"
Write-Host "Log: $logPath"

if ($exitCode -ge 8) {
    throw "Robocopy reported at least one copy failure. Review the log."
}
