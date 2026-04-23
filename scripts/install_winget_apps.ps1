# install_winget_apps.ps1 — install Windows applications via winget.
#
# Reads a newline-delimited list from apps/windows_programs.txt.
# Blank lines and lines starting with '#' are ignored so the list can
# be annotated. Safe to re-run: winget's "already installed" exit code
# is treated as success, so a second run is a no-op.
#
# Unlike the brew/pacman/apt cases, the Windows base deps (git, vim,
# Windows Terminal) also live in windows_programs.txt — adamweld.conf.yaml
# cannot call winget idempotently, so all winget installs are funnelled
# through this script instead.

$BASEDIR = Split-Path -Parent $PSScriptRoot
$APPS_FILE = Join-Path $BASEDIR "apps\windows_winget.txt"

# APPINSTALLER_CLI_ERROR_PACKAGE_ALREADY_INSTALLED — treat as success.
$ALREADY_INSTALLED = -1978335189

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "winget not found. Install 'App Installer' from the Microsoft Store."
    exit 1
}

if (-not (Test-Path $APPS_FILE)) {
    Write-Error "Package list not found: $APPS_FILE"
    exit 1
}

$packages = Get-Content $APPS_FILE |
    ForEach-Object { ($_ -replace '#.*$', '').Trim() } |
    Where-Object { $_ -ne '' }

if (-not $packages) {
    Write-Output "No packages listed in $APPS_FILE; nothing to do."
    return
}

Write-Output "Installing $($packages.Count) winget package(s) from ${APPS_FILE}:"
foreach ($pkg in $packages) {
    Write-Output "  -> winget install --id $pkg"
    & winget install --id $pkg -e --accept-package-agreements --accept-source-agreements --silent
    $code = $LASTEXITCODE
    if ($code -eq 0) {
        continue
    } elseif ($code -eq $ALREADY_INSTALLED) {
        Write-Output "     (already installed)"
    } else {
        Write-Output "     (failed: exit $code)"
    }
}
Write-Output "Done."
