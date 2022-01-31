$module = 'ww.PSUtilities'

Set-Location $PSScriptRoot

# Clean build output directory if it already exists
if (Test-Path "$PSScriptRoot\output" -PathType Container) {
    Get-ChildItem "$PSScriptRoot\output\*" -Recurse -Force | Remove-Item -Recurse
}

dotnet build "$PSScriptRoot\src" -o "$PSScriptRoot\output\$module\bin"
Copy-Item "$PSScriptRoot\$module\*" "$PSScriptRoot\output\$module" -Recurse -Force
