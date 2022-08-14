# gitconfig
if (-not (Test-Path "${env:USERPROFILE}\.gitconfig")) {
  Write-Output "[include]`n  path = ~/.dotfiles/git/gitconfig-entrypoint" > "${env:USERPROFILE}\.gitconfig"
}
if (-not (Test-Path "${env:USERPROFILE}\.gitignore")) {
  New-Item -Path ${env:USERPROFILE}\.gitignore -ItemType SymbolicLink -Value "${env:USERPROFILE}\.dotfiles\gitignore_global"
}

# powershell profile
if (-not (Test-Path $PROFILE.CurrentUserAllHosts\profile.ps1)) {
  Write-Output ". ${env:USERPROFILE}\.dotfiles\Powershell-Profile\profile.ps1`n. ${env:USERPROFILE}\.dotfiles\Powershell-Profile\psfunctions.ps1`n. ${env:USERPROFILE}\.dotfiles\Powershell-Profile\psaliases.ps1" > $PROFILE.CurrentUserAllHosts
}
