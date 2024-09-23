param (
    [string]$playlistsPath = "" # Default directory of the playlists downloaded
)

if (-not $playlistsPath) {
    Write-Host "Please specify the download path either in the script or as a command line argument." -ForegroundColor Yellow
    Write-Host "Usage: .\xspfall.ps1 [<Optional: Download Path>]" -ForegroundColor Magenta
    exit
}

$originalPath = Get-Location
$xspfScript = Join-Path $originalPath  "xspf.ps1"
$playlistDirectories = Get-ChildItem -Path $playlistsPath -Directory

foreach ($dir in $playlistDirectories) {
    try {
        & $xspfScript -playlistPath $dir.FullName
    } catch {
        Write-Host "Error occurred while running xspf.ps1:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}