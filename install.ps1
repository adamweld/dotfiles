[CmdletBinding()]
param(
    # Escape hatch for the symlink preflight below. Only useful when the
    # links already exist and you just want the create/shell tasks to run.
    [switch]$SkipPreflight,

    # Everything else is forwarded to dotbot verbatim.
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$DotbotArgs
)

$ErrorActionPreference = "Stop"

$CONFIG = "adamweld.conf.yaml"
$DOTBOT_DIR = "dotbot"
$DOTBOT_BIN = "bin/dotbot"
$PLUGINS_DIR = ".plugins"
$BASEDIR = $PSScriptRoot
Set-Location $BASEDIR

$DOTBOT_CMD =   $(Join-Path $BASEDIR -ChildPath $DOTBOT_DIR | Join-Path -ChildPath $DOTBOT_BIN)
$PLUGINS_CMD = @(Get-ChildItem -Directory $PLUGINS_DIR -ErrorAction SilentlyContinue |
                 ForEach-Object { "--plugin-dir", "$PLUGINS_DIR/$($_.Name)" })

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

# Re-read PATH from the registry. A winget install updates the *stored* PATH,
# but this process inherited its own copy at launch and will never see the new
# entries -- which matters right after bootstrapping Python below.
function Update-PathFromRegistry {
    $machine = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $user    = [Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = @($machine, $user | Where-Object { $_ }) -join ";"
}

# Windows ships stub python.exe/python3.exe under WindowsApps whose only job is
# to open the Microsoft Store. They sit on PATH by default, so a naive lookup
# "finds" a Python that can never run dotbot. Reject them by path.
function Test-IsStoreStub {
    param([string]$Path)
    return $Path -like "*\Microsoft\WindowsApps\*"
}

# Returns @{ Exe; Pre; Version } for the first usable interpreter, else $null.
function Resolve-Python {
    # The 'py' launcher goes first: it knows about every registered install and
    # is never a Store stub. The bare names follow, to cover PATH-only installs
    # (venv, conda, MSYS) that the launcher doesn't track.
    $candidates = @(
        @{ Exe = "py";      Pre = @("-3") },
        @{ Exe = "python";  Pre = @() },
        @{ Exe = "python3"; Pre = @() }
    )

    foreach ($candidate in $candidates) {
        $cmd = Get-Command $candidate.Exe -ErrorAction SilentlyContinue |
               Select-Object -First 1
        if (-not $cmd) { continue }
        if (Test-IsStoreStub $cmd.Source) { continue }

        $version = $null
        # Seed a non-zero sentinel: if the exe fails to launch at all, the
        # check below must not read a stale 0 from some earlier command.
        $global:LASTEXITCODE = 1
        try {
            $ErrorActionPreference = "SilentlyContinue"
            $version = & $cmd.Source (@($candidate.Pre) + @("-V"))
        } catch {
            $version = $null
        } finally {
            $ErrorActionPreference = "Stop"
        }

        if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace("$version")) {
            return @{
                Exe     = $cmd.Source
                Pre     = $candidate.Pre
                Version = "$version".Trim()
            }
        }
    }
    return $null
}

# Every other winget install is funnelled through scripts/install_winget_apps.ps1
# (see the note in adamweld.conf.yaml). Python is the one deliberate exception:
# dotbot *is* a Python program, so it cannot be the thing that installs the
# interpreter it depends on. Without this, a fresh Windows box has to install
# Python by hand before any of this repo works.
function Install-PythonViaWinget {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        return $false
    }

    $pkg = "Python.Python.3.11"
    Write-Output "Python not found -- bootstrapping $pkg via winget..."
    & winget install --id $pkg -e --accept-package-agreements --accept-source-agreements --silent
    $code = $LASTEXITCODE

    # APPINSTALLER_CLI_ERROR_PACKAGE_ALREADY_INSTALLED counts as success.
    if ($code -ne 0 -and $code -ne -1978335189) {
        Write-Output "  winget install failed (exit $code)"
        return $false
    }

    Update-PathFromRegistry
    return $true
}

# dotbot's 'link' directive calls os.symlink(), which on Windows needs
# SeCreateSymbolicLinkPrivilege -- granted only by Developer Mode or an
# elevated shell. Without it every link fails. That matters more than it looks:
# ~/.gitconfig is configured force:true, so dotbot *deletes* the existing file
# and only then discovers it cannot create the link. Check up front so a run
# that cannot succeed never destroys anything.
#
# The probe MUST go through Python rather than PowerShell's
# `New-Item -ItemType SymbolicLink`. Under Developer Mode the two disagree:
# CPython passes SYMBOLIC_LINK_FLAG_ALLOW_UNPRIVILEGED_CREATE to
# CreateSymbolicLinkW and succeeds unelevated, while Windows PowerShell 5.1
# does not and still fails. Probing with New-Item would therefore block runs
# that dotbot would in fact complete.
function Test-SymlinkPrivilege {
    param([hashtable]$Python)

    $probeScript = @'
import os, sys, tempfile, uuid
target = sys.argv[1]
link = os.path.join(tempfile.gettempdir(), "dotbot-symlink-probe-" + uuid.uuid4().hex)
try:
    os.symlink(target, link, target_is_directory=True)
except OSError:
    sys.exit(1)
try:
    os.remove(link)
except OSError:
    pass
sys.exit(0)
'@
    $probeFile = Join-Path ([IO.Path]::GetTempPath()) ("dotbot-symlink-probe-" + [guid]::NewGuid().ToString("N") + ".py")
    Set-Content -Path $probeFile -Value $probeScript -Encoding utf8
    try {
        $global:LASTEXITCODE = 1
        $ErrorActionPreference = "SilentlyContinue"
        & $Python.Exe (@($Python.Pre) + @($probeFile, $BASEDIR)) | Out-Null
        return ($LASTEXITCODE -eq 0)
    } finally {
        $ErrorActionPreference = "Stop"
        Remove-Item $probeFile -Force -ErrorAction SilentlyContinue
    }
}

# ---------------------------------------------------------------------------
# Run
# ---------------------------------------------------------------------------

Write-Output "Dotfiles Repo Status:"
git status
git submodule sync --quiet --recursive
git submodule update --init --recursive $BASEDIR

$python = Resolve-Python
if (-not $python) {
    if (Install-PythonViaWinget) {
        $python = Resolve-Python
    }
}

if (-not $python) {
    Write-Error @"
Cannot find Python, and could not bootstrap it automatically.

dotbot is written in Python, so it needs a real interpreter. Note that the
python.exe / python3.exe shims under WindowsApps are Microsoft Store stubs and
do not count -- this script deliberately ignores them.

Install it, then re-run:
  winget install --id Python.Python.3.11 -e --source winget
"@
    exit 1
}

Write-Output "Using $($python.Version) ($($python.Exe))"

if (-not $SkipPreflight -and -not (Test-SymlinkPrivilege -Python $python)) {
    Write-Error @"
Cannot create symbolic links on this machine, so every 'link' task would fail.

Windows only grants SeCreateSymbolicLinkPrivilege to Developer Mode or to an
elevated shell. Pick one, then re-run this script:

  1. Enable Developer Mode (one-time, preferred -- no elevation afterwards).
     Settings > Privacy & security > For developers > Developer Mode
     Or from an *elevated* PowerShell:
       New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock' ``
         -Name AllowDevelopmentWithoutDevLicense -Value 1 -PropertyType DWord -Force
     Developer Mode normally applies to new processes right away; if the probe
     still fails, sign out and back in.

  2. Or just re-run this script from an elevated PowerShell.

Use -SkipPreflight to run anyway (link tasks will fail).
"@
    exit 1
}

Write-Output "Executing Dotbot:"

# Filter empties: an unbound $DotbotArgs is $null, and @($null) would otherwise
# hand dotbot a bogus empty-string argument.
$invocation = @($python.Pre) +
              @($DOTBOT_CMD, "--base-directory", $BASEDIR, "--config-file", $CONFIG) +
              @($PLUGINS_CMD) +
              @($DotbotArgs)
$invocation = $invocation | Where-Object { -not [string]::IsNullOrEmpty($_) }

& $python.Exe $invocation
exit $LASTEXITCODE
