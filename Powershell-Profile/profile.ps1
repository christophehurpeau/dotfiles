
function Prompt {
  Write-Host "`n$env:USERNAME" -ForegroundColor Green -NoNewline
  if (Get-IsAdministrator) {
    Write-Host " as " -NoNewline
    Write-Host "Administrator" -ForegroundColor Red -NoNewline
  }
  Write-Host " " -NoNewline
  Write-Host $env:COMPUTERNAME -ForegroundColor Magenta -NoNewline
  Write-Host " " -NoNewline
  Write-Host $ExecutionContext.SessionState.Path.CurrentLocation -ForegroundColor Cyan
  return "PS $('>' * ($NestedPromptLevel + 1)) "
}
