$Scripts = @(Get-ChildItem "$PSScriptRoot\Public" -Recurse -Include *.ps1)

foreach ($Script in $Scripts) {
    . $Script
}