#Requires -Version 5.1
param(
  [Parameter(Mandatory)][string]$Url,
  [string]$OutDir = ".",
  [switch]$AudioOnly,
  [string]$Format = "",
  [switch]$Subs
)
$Root = Split-Path -Parent $PSCommandPath; . "$Root\lib\common.ps1"
Require-Tool yt-dlp
Ensure-Dir $OutDir
$args = @('-o', (Join-Path (Resolve-Path $OutDir) '%(title)s.%(ext)s'))
if ($AudioOnly){
  $audioFmt = 'mp3'
  if ($Format -and $Format -ne "") { $audioFmt = $Format }
  $args += @('-f','bestaudio','--extract-audio','--audio-format', $audioFmt)
}
if ($Subs){ $args += @('--write-subs','--sub-langs','all') }
if (-not $AudioOnly -and $Format){ $args += @('-f',"bv*+ba/b","--merge-output-format",$Format) }
$args += $Url
if (Exec -File yt-dlp -Args $args){ Fail "yt-dlp failed ($LASTEXITCODE)" }
Ok "downloaded to $OutDir"
