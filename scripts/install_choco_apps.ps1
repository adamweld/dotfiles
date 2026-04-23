# install_choco_apps.ps1 — install Windows applications via Chocolatey.
#
# Reads apps/windows_choco.txt, one package per line. Each line may
# include extra arguments after the package name (e.g. a pinned version):
#     googlechrome --version 109.0.5414.75
# Blank lines and '#' comments are ignored.
#
# Must be run from an elevated shell. Idempotent: choco skips packages
# that are already installed at or above the requested version.

$BASEDIR = Split-Path -Parent $PSScriptRoot
$APPS_FILE = Join-Path $BASEDIR "apps\windows_choco.txt"

if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Error "choco not found. Install Chocolatey first: https://chocolatey.org/install"
    exit 1
}

if (-not (Test-Path $APPS_FILE)) {
    Write-Error "Package list not found: $APPS_FILE"
    exit 1
}

$entries = Get-Content $APPS_FILE |
    ForEach-Object { ($_ -replace '#.*$', '').Trim() } |
    Where-Object { $_ -ne '' }

if (-not $entries) {
    Write-Output "No packages listed in $APPS_FILE; nothing to do."
    return
}

Write-Output "Installing $($entries.Count) choco package(s) from ${APPS_FILE}:"
foreach ($entry in $entries) {
    $tokens = $entry -split '\s+'
    Write-Output "  -> choco install $entry -y"
    & choco install @tokens -y
    if ($LASTEXITCODE -ne 0) {
        Write-Output "     (failed: exit $LASTEXITCODE)"
    }
}
Write-Output "Done."
