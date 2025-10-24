#Requires -Version 5.1
param([Parameter(Mandatory)][int]$Port, [switch]$Force)
$Root = Split-Path -Parent $PSCommandPath; . "$Root\lib\common.ps1"

$pids = [System.Collections.Generic.HashSet[int]]::new()
try {
  $conns = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction Stop
  foreach ($c in $conns) { [void]$pids.Add([int]$c.OwningProcess) }
} catch {
  $lines = & netstat -ano -p tcp | Select-String 'LISTEN'
  foreach ($m in $lines) {
    $cols = ($m.Line -split '\s+').Where({ $_ })
    if ($cols.Count -lt 5) { continue }
    $local = $cols[1]
    $state = $cols[3]
    $pidStr = $cols[4]
    if ($local -match ':(\d+)$') {
      $lp = [int]$Matches[1]
      if ($lp -eq $Port -and $state -like 'LISTEN*') {
        [void]$pids.Add([int]$pidStr)
      }
    }
  }
}

if ($pids.Count -eq 0) { Info "no process is listening on port $Port"; exit 2 }

if ($pids.Count -gt 1 -and -not $Force) {
  Warn "will kill multiple PIDs: $($pids -join ', ')"
  $ans = Read-Host "Proceed? (y/N)"
  if ($ans.ToLower() -ne 'y') { Info "aborted"; exit 1 }
}

$killed = 0
foreach ($targetPid in $pids) {
  & taskkill /F /T /PID $targetPid | Out-Null
  if ($LASTEXITCODE -eq 0) { Ok "killed $targetPid"; $killed++ } else { Warn "failed $targetPid" }
}

if ($killed -gt 0) { exit 0 } else { exit 1 }
