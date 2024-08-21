$ErrorActionPreference = "Stop"

$CONFIG = "adamweld.conf.yaml"
$DOTBOT_DIR = "dotbot"
$DOTBOT_BIN = "bin/dotbot"
$PLUGINS_DIR = "plugins"
$BASEDIR = $PSScriptRoot
Set-Location $BASEDIR

$DOTBOT_CMD =   $(Join-Path $BASEDIR -ChildPath $DOTBOT_DIR | Join-Path -ChildPath $DOTBOT_BIN) 
$PLUGINS_CMD = @(Get-ChildItem -Directory $PLUGINS_DIR | ForEach-Object { "--plugin-dir", "$PLUGINS_DIR/$($_.Name)" })

Write-Output "Dotfiles Repo Status:"
git status
git submodule sync --quiet --recursive
git submodule update --init --recursive $BASEDIR

Write-Output "Executing Dotbot:"
foreach ($PYTHON in ('python', 'python3', 'python2')) {
    # Python redirects to Microsoft Store in Windows 10 when not installed
    if (& { $ErrorActionPreference = "SilentlyContinue"
            ![string]::IsNullOrEmpty((&$PYTHON -V))
            $ErrorActionPreference = "Stop" }) {
        & $PYTHON $DOTBOT_CMD --base-directory $BASEDIR --config-file $CONFIG $PLUGINS_CMD $Args
        return
    }
}
Write-Error "Error: Cannot find Python."
