param (
    [string]$playlistPath
)

# Check if playlistPath exists
if (-not $playlistPath) {
    Write-Host "Please specify the download path either in the script or as a command line argument." -ForegroundColor Yellow
    Write-Host "Usage: .\mpd.ps1 <Playlist Path>" -ForegroundColor Magenta
    exit
} elseif (-not (Test-Path -Path $playlistPath)) {
    Write-Host "Playlist directory was not found:" -ForegroundColor Yellow
    Write-Host "`t$playlistPath"
    exit
}

$originalPath = Get-Location
$missingTracksFile = Join-Path $playlistPath ".info\missing_tracks.txt"
Set-Location $playlistPath

# Read missing_tracks.txt and download the manually add musics
if (Test-Path -Path $missingTracksFile) {
    $missingTracks = Get-Content $missingTracksFile | Where-Object { $_ -match "\|" }
    if ($missingTracks.Count -gt 0) {
        Write-Host "Processing manually added tracks for: $($dir.Name)" -ForegroundColor Cyan
        foreach ($track in $missingTracks) {
            # TODO: see a better way of doing this
            $splitTrack = $track -split "\|"
            $sourceTrack = $splitTrack[1] -split " -"
            $nameTrack = $splitTrack[1] -split ": "

            $nameTrack = $nameTrack[2]
            $sourceUrl = $splitTrack[0].Trim()
            $spotifyUrl = $sourceTrack[0].Trim()

            Write-Host "Downloading manually added track: $nameTrack" -ForegroundColor Cyan

            # Download the manually added track
            Invoke-Expression "spotdl download '$sourceUrl|$spotifyUrl'"
        }
    } else {
        Write-Host "No manually added tracks found in missing_tracks for '$($dir.Name)'" -ForegroundColor Yellow
    }
}

Set-Location -Path $originalPath