$content = @"
param (
    [string]`$Command,
    [Parameter(ValueFromRemainingArguments = `$true)]
    [string[]]`$Args
)

function Find-From-Main {
    param (
        [string]`$FileToFind
    )

    `$currentDir = [System.IO.DirectoryInfo]::new((Get-Location).Path)

    # move up main dir
    while (`$currentDir -ne `$null) {
        Write-Host "Current Directory: `$(`$currentDir.FullName)"
        if (`$currentDir.Name -eq "main") {
            break
        }
        `$currentDir = `$currentDir.Parent
    }

    # search main dir
    if (`$currentDir -ne `$null -and `$currentDir.Name -eq "main") {
        `$found = Get-ChildItem -Path `$currentDir.FullName -Recurse -File -Filter `$FileToFind -ErrorAction SilentlyContinue | Select-Object -First 1
        if (`$found) {
            Write-Host "`$(`$found.FullName)"
            return `$found.FullName
        }
    }
    return `$null
}

function terraform {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromRemainingArguments = `$true)]
        [string[]]`$Args
    )

    # search file name
    `$filename = "win_wrapper.ps1"

    # file search 
    `$wrapperPath = Find-From-Main -FileToFind `$filename

    # file exists
    if ((`$wrapperPath -ne `$null) -and (Test-Path `$wrapperPath)) {
        Write-Host "Found and running win_wrapper.ps1"
        & `$wrapperPath @Args
    } else {
        Write-Host "win_wrapper.ps1 not found"
        & terraform.exe @Args
    }
}
"@

$profilePath = $PROFILE
if (!(Get-Content -Path $profilePath | Select-String -Pattern 'function terraform')) {
    Add-Content -Path $profilePath -Value $content
    Write-Host "Content added to profile"
} else {
    Write-Host "Content already exists in profile"
}
