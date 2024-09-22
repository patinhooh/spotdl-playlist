param (
    [switch]$xspf,              # A flag parameter for creating XSPF files
    [string]$playlistsPath = "" # Default directory of the playlists downloaded
)

# Check if playlistsPath exists
if (-not $playlistsPath) {
    Write-Host "Please specify the download path either in the script or as a command line argument." -ForegroundColor Yellow
    Write-Host "Usage: .\updall.ps1 [<Optional: Playlists Path>] [-xspf]" -ForegroundColor Magenta
    exit
} elseif (-not (Test-Path -Path $playlistsPath)) {
    Write-Host "Playlists directory was not found:" -ForegroundColor Yellow
    Write-Host "`t$playlistsPath"
    exit
}

$originalPath = Get-Location
$updScript = Join-Path $originalPath  "upd.ps1"
$mpdScript = Join-Path $originalPath  "mpd.ps1"
$xspfScript = Join-Path $originalPath  "xspf.ps1"
$playlistDirectories = Get-ChildItem -Path $playlistsPath -Directory

foreach ($dir in $playlistDirectories) {
    $infoPath = Join-Path $dir.FullName ".info"
    $missingTracksFile = Join-Path $infoPath "missing_tracks.txt"

    # upd playlist
    try {
        & $updScript -playlistPath $dir.FullName
    } catch {
        Write-Host "Error occurred while running upd.ps1:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    } 

    # manually added tracks 
    try {
        & $mpdScript -missingTracksFile $missingTracksFile -playlistPath $dir.FullName
    } catch {
        Write-Host "Error occurred while running mpd.ps1:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    } 

    # Create xspf file for playlist
    if($xspf){
        try {
            & $xspfScript -playlistPath $dir.FullName
        } catch {
            Write-Host "Error occurred while running xspf.ps1:" -ForegroundColor Red
            Write-Host $_.Exception.Message -ForegroundColor Red
        } 
    }
}

Set-Location -Path $originalPath
Write-Host "All playlists updated." -ForegroundColor Green