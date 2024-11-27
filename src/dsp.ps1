param (
    [switch]$xspf,              # A flag parameter for creating XSPF files
    [string]$playlistName,      # Name of the playlist to download
    [string]$playlistUrl,       # URL of the Spotify playlist
    [string]$downloadPath = ""  # Default download path
)

if (-not $downloadPath) {
    Write-Host "Please specify the download path either in the script or as a command line argument." -ForegroundColor Yellow
    Write-Host "Usage: .\dsp.ps1 <Directory Name> <Spotify URL> [<Optional: Download Path>] [-xspf]" -ForegroundColor Magenta
    exit
}

if (-not $playlistUrl -or -not $playlistName) {
    Write-Host "Usage: .\dsp.ps1 <Directory Name> <Spotify URL> [<Optional: Download Path>] [-xspf]" -ForegroundColor Magenta
    exit
}

$originalPath = Get-Location
# Convert to Full Path
$downloadPath = $downloadPath | Resolve-Path
$playlistPath = Join-Path $downloadPath $playlistName
$playlistPath = $playlistPath -replace "'","`'"


$infoPath = Join-Path $playlistPath ".info"           
$xspfScript = Join-Path $originalPath  "xspf.ps1"

# Attempt to create the playlist directory
try {
    if (-not (Test-Path -Path $playlistPath)) {
        New-Item -Path $playlistPath -ItemType Directory -ErrorAction Stop | Out-Null
        Write-Host "Created directory:" -ForegroundColor Green
        Write-Host "    '$playlistPath'"
    } else {
        Write-Host "Directory already exists:" -ForegroundColor Yellow
        Write-Host "    '$playlistPath'"
        exit
    }
} catch {
    Write-Host "Failed to create directory:" -ForegroundColor Red
    Write-Host "    '$playlistPath'"
    Write-Host "Error:`r`n$_" -ForegroundColor Red
    exit
}

# Attempt to create the .info directory
try {
    if (-not (Test-Path -Path $infoPath)) {
        New-Item -Path $infoPath -ItemType Directory -ErrorAction Stop | Out-Null
        Write-Host "Created directory for info:" -ForegroundColor Green
        Write-Host "    '$infoPath'"
    } else {
        Write-Host "Directory already exists:" -ForegroundColor Yellow
        Write-Host "    '$infoPath'"
        exit
    }
} catch {
    Write-Host "Failed to create .info directory:" -ForegroundColor Red
    Write-Host "    '$infoPath'"
    Write-Host "Error:`r`n$_"-ForegroundColor Red
    exit
}

# Change to the new playlist directory
try {
    Set-Location -Path $playlistPath -ErrorAction Stop
} catch {
    Write-Host "Failed to set location to:" -ForegroundColor Red
    Write-Host "    '$playlistPath'"
    Write-Host "Error:`r`n$_" -ForegroundColor Red
    exit
}

# spotdl command to synchronize the playlist
$command = "spotdl sync $playlistUrl --save-file '$infoPath\sync.spotdl' --save-errors '$infoPath\missing_tracks.txt'"
Write-Host $command -ForegroundColor Magenta
try {
    Invoke-Expression $command
    Write-Host "spotdl finished.`r`n" -ForegroundColor Magenta
} catch {
    Write-Host "spotdl failed." -ForegroundColor Red
    Write-Host "Error:`r`n$_" -ForegroundColor Red

    # Cleanup if the command fails
    if (Test-Path -Path $playlistPath) {
        Remove-Item -Path $playlistPath -Recurse -Force
        Write-Host "Removed playlist directory that was created:" -ForegroundColor Yellow
        Write-Host "    '$playlistPath'"
    }
    Set-Location -Path $originalPath
    exit
}

# Check if any tracks are missing after the download
if (Test-Path -Path "$infoPath\missing_tracks.txt") {
    $missingTracks = Get-Content "$infoPath\missing_tracks.txt"
    if ($missingTracks.Length -gt 0) {
        Write-Host "`r`nSome tracks were not found." -ForegroundColor Yellow
        Write-Host "Check the missing tracks in:" -ForegroundColor Yellow
        Write-Host "    '$infoPath\missing_tracks.txt'" 
    } else {
        Write-Host "`r`nAll tracks were successfully downloaded." -ForegroundColor Green
        Remove-Item -Path "$infoPath\missing_tracks.txt" -Force

        # Create xspf file for playlist
        if($xspf){
            try {
                & $xspfScript -playlistPath $playlistPath
            } catch {
                Write-Host "Error occurred while running xspf.ps1:" -ForegroundColor Red
                Write-Host "`r`n$_" -ForegroundColor Red
            } 
        }
    }
}

Set-Location -Path $originalPath
Write-Host "Playlist '$playlistName' downloaded.`r`n" -ForegroundColor Green
Write-Host ""
