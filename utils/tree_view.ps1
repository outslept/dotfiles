function Show-TreeView {
    param (
        [string]$Path = ".",
        [int]$Depth = [int]::MaxValue
    )

    function Show-Tree {
        param (
            [string]$CurrentPath,
            [string]$Indent = "",
            [int]$CurrentDepth = 0
        )

        if ($CurrentDepth -ge $Depth) {
            return
        }

        $items = Get-ChildItem -Path $CurrentPath -Force

        foreach ($item in $items) {
            if ($item.PSIsContainer) {
                Write-Host "$Indent📁 $($item.Name)"
                Show-Tree -CurrentPath $item.FullName -Indent "$Indent│   " -CurrentDepth ($CurrentDepth + 1)
            }
            else {
                Write-Host "$Indent📄 $($item.Name)"
            }
        }
    }

    $Path = Resolve-Path $Path
    Write-Host "📁 $Path"
    Show-Tree -CurrentPath $Path
}
