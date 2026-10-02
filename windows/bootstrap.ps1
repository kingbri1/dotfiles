if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    $installer = Join-Path $env:TEMP "scoop-install.ps1"

    Invoke-RestMethod "https://get.scoop.sh" -OutFile $installer
    & $installer
    Remove-Item $installer -Force
}

$env:PATH = "$HOME\scoop\shims;$env:PATH"

# Run second mise instance since scoop is on the child path
mise bootstrap packages apply --manager scoop --yes

