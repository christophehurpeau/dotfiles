
function Get-IsAdministrator {
  <#
  .Synopsis
  Return True if you are currently running PowerShell as an administrator, False otherwise.
  #>
  $user = [Security.Principal.WindowsIdentity]::GetCurrent()
  (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function Get-CmdletAlias ($cmdletname) {
  Get-Alias |
  Where-Object -FilterScript { $_.Definition -like "$cmdletname" } |
  Format-Table -Property Definition, Name -AutoSize
}
