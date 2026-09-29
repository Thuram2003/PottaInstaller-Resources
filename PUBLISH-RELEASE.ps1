param(
    [string]$Version = "",
    [string]$ReleaseRepoDir = "$env:USERPROFILE\source\repos\potta-releases",
    [string]$ReleaseRepoSlug = "Instanvi/potta-releases",
    [string]$ChangelogSummary = "Stability and reliability improvements.",
    [string]$ReleaseNotesUrl = ""
)

$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $false

function Require-Command([string]$Name) {
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required command '$Name' was not found in PATH."
    }
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootDir = Split-Path -Parent $scriptDir
$versionFile = Join-Path $rootDir "VERSION.txt"

if ([string]::IsNullOrWhiteSpace($Version)) {
    if (-not (Test-Path $versionFile)) {
        throw "VERSION.txt not found at: $versionFile"
    }
    $Version = (Get-Content $versionFile -Raw).Trim()
}

if ([string]::IsNullOrWhiteSpace($Version)) {
    throw "Version is empty. Set VERSION.txt or pass -Version."
}

$installerPath = Join-Path $scriptDir ("installer-output\PottaSetup_v{0}.exe" -f $Version)
if (-not (Test-Path $installerPath)) {
    throw "Installer not found: $installerPath`nRun BUILD-INSTALLER.bat first."
}

Require-Command "git"
Require-Command "gh"

if (-not (Test-Path $ReleaseRepoDir)) {
    Write-Host "[INFO] Cloning $ReleaseRepoSlug to $ReleaseRepoDir ..."
    gh repo clone $ReleaseRepoSlug $ReleaseRepoDir
}

if (-not (Test-Path (Join-Path $ReleaseRepoDir ".git"))) {
    throw "Release repo directory exists but is not a git repository: $ReleaseRepoDir"
}

Push-Location $ReleaseRepoDir
try {
    git pull --ff-only

    $tag = "v$Version"
    $assetName = "PottaSetup_v$Version.exe"
    $downloadUrl = "https://github.com/$ReleaseRepoSlug/releases/download/$tag/$assetName"

    $updateJsonPath = Join-Path $ReleaseRepoDir "update.json"
    $manifest = [ordered]@{
        version = $Version
        downloadUrl = $downloadUrl
        changelog = [ordered]@{
            summary = $ChangelogSummary
            fullNotesUrl = if ([string]::IsNullOrWhiteSpace($ReleaseNotesUrl)) {
                "https://github.com/$ReleaseRepoSlug/releases/tag/$tag"
            } else {
                $ReleaseNotesUrl
            }
        }
    }

    $manifest | ConvertTo-Json -Depth 5 | Set-Content -Path $updateJsonPath -Encoding UTF8

    git add update.json
    $status = git status --porcelain
    if ($status) {
        git commit -m "Update manifest for $tag"
        git push
    } else {
        Write-Host "[INFO] update.json unchanged. Skipping commit."
    }

    cmd /c "gh release view $tag --repo $ReleaseRepoSlug >nul 2>nul"
    $releaseExists = ($LASTEXITCODE -eq 0)

    if (-not $releaseExists) {
        cmd /c "gh release create $tag --repo $ReleaseRepoSlug --target main --title ""Potta Finance $Version"" --notes ""$ChangelogSummary"""
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to create release '$tag' in $ReleaseRepoSlug."
        }
    }

    cmd /c "gh release upload $tag ""$installerPath"" --repo $ReleaseRepoSlug --clobber"
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to upload installer asset for release '$tag'."
    }

    Write-Host ""
    Write-Host "[OK] Release published successfully."
    Write-Host "Tag: $tag"
    Write-Host "Manifest: https://raw.githubusercontent.com/$ReleaseRepoSlug/main/update.json"
    Write-Host "Release:  https://github.com/$ReleaseRepoSlug/releases/tag/$tag"
}
finally {
    Pop-Location
}
