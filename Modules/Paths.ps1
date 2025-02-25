# Show-SortedPaths function
# This script sorts the system PATH variable and displays it in color-coded format.
function Show-SortedPaths {
    $paths = $env:Path -split ';'

    $sortedPaths = $paths | Sort-Object

    foreach ($path in $sortedPaths) {
        switch -Regex ($path) {
            '^C:\\Program Files' { Write-Host $path -ForegroundColor Blue; break }
            '^C:\\Users' { Write-Host $path -ForegroundColor Yellow; break }
            '^C:\\Windows' { Write-Host $path -ForegroundColor Green; break }
            default { Write-Host $path -ForegroundColor White }
        }
    }
}

# Set-Path function
# This function sets a new path variable to the specified path.
function Set-Path {
    param (
        [string]$newPath
    )

    # Set a new path variable to the specified path
    if ($env:Path -notmatch [regex]::Escape($newPath)) {
        $env:Path += ";$newPath"
    }
}
