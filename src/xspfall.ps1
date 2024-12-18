param (
    [string]$playlistsPath = "", # Default directory of the playlists downloaded
    [switch]$abs
)

if (-not $playlistsPath) {
    Write-Host "Please specify the download path either in the script or as a command line argument." -ForegroundColor Yellow
    Write-Host "Usage: .\xspfall.ps1 [<Optional: Download Path>] [-abs]" -ForegroundColor Magenta
    exit
}

$originalPath = Get-Location
$playlistsPath = $playlistsPath | Resolve-Path
$xspfScript = Join-Path $originalPath  "xspf.ps1"
$playlistDirectories = Get-ChildItem -Path $playlistsPath -Directory

foreach ($dir in $playlistDirectories) {
    try {
        if ($abs){
            & $xspfScript -playlistPath $dir.FullName -abs
        }
        else{
            & $xspfScript -playlistPath $dir.FullName
        }
    } catch {
        Write-Host "Error occurred while running xspf.ps1:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}