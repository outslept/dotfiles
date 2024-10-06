$extensions = code --list-extensions | Sort-Object

$extensions | Out-File -FilePath .\plugin-list.txt -Encoding utf8
