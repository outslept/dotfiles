
function Install-Extension($extensionId) {
    Write-Host "Installing extension: $extensionId"
    & code --install-extension $extensionId
}

$pluginListPath = "..\plugin-list.txt"

if (-not (Test-Path $pluginListPath)) {
    Write-Error "Plugin list file not found: $pluginListPath"
    exit 1
}

$extensions = Get-Content $pluginListPath | Where-Object { $_ -match '\S' }

$totalExtensions = $extensions.Count
$currentExtension = 0

foreach ($extension in $extensions) {
    $currentExtension++
    Write-Progress -Activity "Installing Extensions" -Status "Progress" -PercentComplete (($currentExtension / $totalExtensions) * 100)
    
    Install-Extension $extension
}

Write-Host "All extensions have been installed successfully!"
