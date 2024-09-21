param (
    [string]$playlistsPath = "" # Default directory of the playlists downloaded
)

# Check if playlistsPath exists
if (-not $playlistsPath) {
    Write-Host "Please specify the download path either in the script or as a command line argument." -ForegroundColor Yellow
    Write-Host "Usage: .\upd.ps1 [<Optional: Playlists Path>]" -ForegroundColor Magenta
    exit
} elseif (-not (Test-Path -Path $playlistsPath)) {
    Write-Host "Playlists directory was not found:" -ForegroundColor Yellow
    Write-Host "`t$playlistsPath"
    exit
}

$originalPath = Get-Location
$ManuallyUpdScript = Join-Path $originalPath  "mpd.ps1"
$playlistDirectories = Get-ChildItem -Path $playlistsPath -Directory

foreach ($dir in $playlistDirectories) {
    $infoPath = Join-Path $dir.FullName ".info"
    $syncFilePath = Join-Path $infoPath "sync.spotdl"
    $missingTracksFile = Join-Path $infoPath "missing_tracks.txt"

    # Check if sync.spotdl file exists and sync the playlist
    if (Test-Path -Path $syncFilePath) {
        Write-Host "Syncing playlist: $($dir.Name)" -ForegroundColor Magenta
        Set-Location -Path $dir.FullName
        
        # Execute the spotdl command
        try {
            Invoke-Expression "spotdl sync `"$syncFilePath`" --sync-without-deleting"
        } catch {
            Write-Host "Failed to sync playlist: $($dir.Name)" -ForegroundColor Red
            Write-Host "Error:`r`n$_" -ForegroundColor Red
        }

        # Check for manually added tracks in the missing_tracks file
        try {
            & $ManuallyUpdScript -missingTracksFile $missingTracksFile -playlistPath $dir.FullName
        } catch {
            Write-Host "Error occurred in mpd.ps1:" -ForegroundColor Red
            Write-Host $_.Exception.Message -ForegroundColor Red
        }
    } else {
        Write-Host "No sync file found for directory: $($dir.Name)" -ForegroundColor Yellow
    }
}

# Return to the original directory
Set-Location -Path $originalPath
Write-Host "All playlists updated." -ForegroundColor Green