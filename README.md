# dotfiles
```
ssh-keygen -t ed25519 -C adam.weld@gmail.com

winget upgrade 9nblggh4nns1
winget install --id Git.Git -e --source winget

cd ~
git clone git@github.com:adamweld/dotfiles.git
./dotfiles/install
```

On Windows, app installs are split out from the dotbot run (winget is not
idempotent from inside dotbot). After `./dotfiles/install.ps1`, run either
or both of these installer scripts — their package lists live under `apps/`:

```
# Non-elevated: winget apps (apps/windows_winget.txt)
powershell -ExecutionPolicy Bypass -File scripts\install_winget_apps.ps1

# Elevated shell: chocolatey apps (apps/windows_choco.txt)
powershell -ExecutionPolicy Bypass -File scripts\install_choco_apps.ps1
```
