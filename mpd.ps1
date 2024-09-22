param (
    [string]$playlistPath
)

if (-not $playlistPath) {
    Write-Host "Usage: .\mpd.ps1 <Playlist Path>" -ForegroundColor Magenta
    exit
} elseif (-not (Test-Path -Path $playlistPath)) {
    Write-Host "Playlist directory was not found:" -ForegroundColor Yellow
    Write-Host "`t$playlistPath"
    exit
}

$originalPath = Get-Location
$missingTracksFile = Join-Path $playlistPath ".info\missing_tracks.txt"

if (-not (Test-Path -Path $missingTracksFile)) {
    Write-Host "No missing tracks file found in the directory:" -ForegroundColor Yellow
    Write-Host "`t$playlistPath"
    exit
}

$missingTracks = Get-Content $missingTracksFile | Where-Object { $_ -match "\|" }
if (-not ($missingTracks.Count -gt 0)) {
    Write-Host "No manually added tracks found in missing tracks." -ForegroundColor Yellow
    exit
}

Write-Host "Processing manually added tracks for:" -ForegroundColor Blue
Write-Host "`t$playlistPath"

# Download the manually add musics
Set-Location -Path $playlistPath
foreach ($track in $missingTracks) {
    $splitLine = $track -split "\s+"
    $nameTrackPart = $track -split ": "
    $downloadPair = $splitLine[0]
    $nameTrack = $nameTrackPart[2]

    Write-Host "Downloading manually added track: $nameTrack" -ForegroundColor Blue
    try {
        Invoke-Expression "spotdl download '$downloadPair'"
    } catch {
        Write-Host "Failed to download music." -ForegroundColor Red
        Write-Host "Error:`r`n$_" -ForegroundColor Red
    }
}

Set-Location -Path $originalPath