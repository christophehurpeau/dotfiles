# gitconfig
if (-not (Test-Path "${env:USERPROFILE}\.gitconfig")) {
  New-Item -Path ${env:USERPROFILE}\.gitconfig -ItemType SymbolicLink -Value "${env:USERPROFILE}\.dotfiles\gitconfig"
}
if (-not (Test-Path "${env:USERPROFILE}\.gitignore")) {
  New-Item -Path ${env:USERPROFILE}\.gitignore -ItemType SymbolicLink -Value "${env:USERPROFILE}\.dotfiles\gitignore_global"
}

# powershell profile
if (-not (Test-Path $PROFILE.CurrentUserAllHosts\profile.ps1)) {
  Write-Output ". ${env:USERPROFILE}\.dotfiles\Powershell-Profile\profile.ps1`n. ${env:USERPROFILE}\.dotfiles\Powershell-Profile\psfunctions.ps1`n. ${env:USERPROFILE}\.dotfiles\Powershell-Profile\psaliases.ps1" > $PROFILE.CurrentUserAllHosts
}
