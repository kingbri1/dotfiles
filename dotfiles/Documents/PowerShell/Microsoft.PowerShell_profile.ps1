[Console]::InputEncoding  = [System.Text.UTF8Encoding]::new()
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$OutputEncoding = [System.Text.UTF8Encoding]::new()

# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
# $ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
# if (Test-Path($ChocolateyProfile)) {
#   Import-Module "$ChocolateyProfile"
# }

if (
    -not [Console]::IsInputRedirected -and
    -not [Console]::IsOutputRedirected -and
    -not $env:ZELLIJ -and
    -not $env:NO_ZELLIJ -and
    (Get-Command zellij -ErrorAction SilentlyContinue)
) {
    zellij
    exit
}
# Mise
(&mise activate pwsh) | Out-String | Invoke-Expression

# Starship
starship init powershell --print-full-init | Out-String | Invoke-Expression
function Invoke-Starship-TransientFunction {
    &starship module character
}

Enable-TransientPrompt

# fzf
Import-Module PSFzf

Set-PsFzfOption `
    -PSReadlineChordProvider 'Ctrl+t' `
    -PSReadlineChordReverseHistory 'Ctrl+r'

# fzf-powered tab completion
Set-PsFzfOption -TabExpansion
Set-PSReadLineKeyHandler -Key Tab -ScriptBlock {
    Invoke-FzfTabCompletion
}

# zoxide
Invoke-Expression (& {
    (zoxide init --cmd cd powershell | Out-String)
})

# Zellij editor
function zedit {
    param(
        [string]$Target = $PWD.Path
    )

    if (Test-Path -Path $Target -PathType Container) {
        $Target = (Resolve-Path $Target).Path
    }

    $oldTarget = $env:ZELLIJ_EDITOR_TARGET

    try {
        $env:ZELLIJ_EDITOR_TARGET = $Target
        zellij --layout editor-windows
    }
    finally {
        if ($null -eq $oldTarget) {
            Remove-Item Env:ZELLIJ_EDITOR_TARGET -ErrorAction SilentlyContinue
        }
        else {
            $env:ZELLIJ_EDITOR_TARGET = $oldTarget
        }
    }
}

function Enter-VsDev {
    $vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"

    if (-not (Test-Path $vswhere)) {
        Write-Error "Visual Studio Installer not found."
        return
    }

    $vsPath = & $vswhere `
        -latest `
        -products * `
        -property installationPath

    if (-not $vsPath) {
        Write-Error "Visual Studio installation not found."
        return
    }

    $vsDevShell = Join-Path $vsPath "Common7\Tools\Launch-VsDevShell.ps1"

    if (-not (Test-Path $vsDevShell)) {
        Write-Error "Launch-VsDevShell.ps1 not found."
        return
    }

    & $vsDevShell `
        -SkipAutomaticLocation `
        -Arch amd64 `
        -HostArch amd64
}

Set-Alias vsdev Enter-VsDev
