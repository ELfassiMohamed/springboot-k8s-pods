# Add graphify-out to .gitignore
$gitignore = ""
if (Test-Path .gitignore) {
    $content = Get-Content .gitignore
    if ($content -notlike "*graphify-out*") {
        Add-Content .gitignore "graphify-out"
        Write-Host "Added graphify-out to .gitignore"
    } else {
        Write-Host "graphify-out already in .gitignore"
    }
}
