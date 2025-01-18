param (
    [switch]$xspf,        # A flag parameter for creating XSPF files
    [string]$playlistPath
)

if (-not $playlistPath) {
    Write-Host "Usage: .\umt.ps1 <Playlist Path> [-xspf]" -ForegroundColor Magenta
    exit
} elseif (-not (Test-Path -Path $playlistPath)) {
    Write-Host "Playlist directory was not found:" -ForegroundColor Yellow
    Write-Host "    '$playlistPath'"
    exit
}

$originalPath = Get-Location
$playlistPath = $playlistPath | Resolve-Path
$missingTracksFile = Join-Path $playlistPath ".info\missing_tracks.txt"
$xspfScript = Join-Path $originalPath  "xspf.ps1"

if (-not (Test-Path -Path $missingTracksFile)) {
    Write-Host "No missing tracks file found in the directory:" -ForegroundColor Yellow
    Write-Host "    '$playlistPath'"
    exit
}

$missingTracks = Get-Content $missingTracksFile | Where-Object { $_ -match "\|" }
if (-not ($missingTracks.Count -gt 0)) {
    Write-Host "No manually added tracks found in missing tracks." -ForegroundColor Yellow
    exit
}

Write-Host "Processing manually added tracks for:" -ForegroundColor Blue
Write-Host "    '$playlistPath'"

# Download the manually add musics
Set-Location -Path $playlistPath
foreach ($track in $missingTracks) {
    # TODO: This can Explode if the lines where edited more then they needed
    $splitSpace = $track -split "\s+"
    $splitDots = $track -split ": "
    $downloadPair = $splitSpace[0]
    $nameTrack = $splitDots[2]

    Write-Host "Downloading manually added track: $nameTrack" -ForegroundColor Blue
    try {
        Invoke-Expression "spotdl download `"$downloadPair`""
    } catch {
        Write-Host "Failed to download music." -ForegroundColor Red
        Write-Host "Error:`r`n$_" -ForegroundColor Red
    }
}

# Create xspf file for playlist
if($xspf){
    try {
        & $xspfScript -playlistPath $playlistPath
    } catch {
        Write-Host "Error occurred while running xspf.ps1:" -ForegroundColor Red
        Write-Host "`r`n$_" -ForegroundColor Red
    } 
}
Write-Host ""
Set-Location -Path $originalPath