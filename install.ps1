# gitconfig
if (-not (Test-Path "${env:USERPROFILE}\.gitconfig")) {
  Write-Output "[include]`n  path = ~/.dotfiles/git/gitconfig-entrypoint.ini" > "${env:USERPROFILE}\.gitconfig"
}
if (-not (Test-Path "${env:USERPROFILE}\.gitignore")) {
  New-Item -Path ${env:USERPROFILE}\.gitignore -ItemType SymbolicLink -Value "${env:USERPROFILE}\.dotfiles\gitignore_global"
}

# powershell profile
if (-not (Test-Path $PROFILE.CurrentUserAllHosts\profile.ps1)) {
  Write-Output ". ${env:USERPROFILE}\.dotfiles\Powershell-Profile\profile.ps1`n. ${env:USERPROFILE}\.dotfiles\Powershell-Profile\psfunctions.ps1`n. ${env:USERPROFILE}\.dotfiles\Powershell-Profile\psaliases.ps1" > $PROFILE.CurrentUserAllHosts
}

# Winget

# -> NodeJS
winget install OpenJS.NodeJS.LTS

# Git & Github
winget install Git.Git
winget install GitHub.GitHubDesktop

# -> GPG to sign git commits & tags
winget install GnuPG.Gpg4win
