param (
    [string]$playlistName,      # Name of the playlist to download
    [string]$playlistUrl,       # URL of the Spotify playlist
    [string]$downloadPath = ""  # Default download path
)

# Check if downloadPath is empty
if (-not $downloadPath) {
    Write-Host "Please specify the download path either in the script or as a command line argument." -ForegroundColor Yellow
    Write-Host "Usage: .\sdl.ps1 <Directory Name> <Spotify URL> [<Optional: Download Path>]" -ForegroundColor Magenta
    exit
}

# Check if required parameters are provided
if (-not $playlistUrl -or -not $playlistName) {
    Write-Host "Usage: .\sdl.ps1 <Directory Name> <Spotify URL> [<Optional: Download Path>]" -ForegroundColor Magenta
    exit
}

$originalPath = Get-Location                           
$directoryPath = Join-Path $downloadPath $playlistName 
$infoPath = Join-Path $directoryPath ".info"           

# Attempt to create the playlist directory
try {
    if (-not (Test-Path -Path $directoryPath)) {
        New-Item -Path $directoryPath -ItemType Directory -ErrorAction Stop | Out-Null
        Write-Host "Created directory:" -ForegroundColor Green
        Write-Host "`t$directoryPath"
    } else {
        Write-Host "Directory already exists:" -ForegroundColor Yellow
        Write-Host "`t$directoryPath"
        # exit
    }
} catch {
    Write-Host "Failed to create directory:" -ForegroundColor Red
    Write-Host "`t$directoryPath"
    Write-Host "Error:`r`n$_" -ForegroundColor Red
    exit
}

# Attempt to create the info directory
try {
    if (-not (Test-Path -Path $infoPath)) {
        New-Item -Path $infoPath -ItemType Directory -ErrorAction Stop | Out-Null
        Write-Host "Created directory for info:" -ForegroundColor Green
        Write-Host "`t$infoPath"
    } else {
        Write-Host "Directory already exists:" -ForegroundColor Yellow
        Write-Host "`t$infoPath"
        # exit
    }
} catch {
    Write-Host "Failed to create .info directory:" -ForegroundColor Red
    Write-Host "`t$infoPath"
    Write-Host "Error:`r`n$_"-ForegroundColor Red
    exit
}

# Change to the new playlist directory
try {
    Set-Location -Path $directoryPath -ErrorAction Stop
} catch {
    Write-Host "Failed to set location to:" -ForegroundColor Red
    Write-Host "`t$directoryPath"
    Write-Host "Error:`r`n$_" -ForegroundColor Red
    exit
}

# Command to synchronize the playlist with spotdl
$command = "spotdl sync $playlistUrl --save-file '$infoPath\sync.spotdl' --save-errors '$infoPath\missing_tracks.txt'"
Write-Host $command -ForegroundColor Magenta

# Execute the spotdl command
try {
    # Invoke-Expression $command
} catch {
    Write-Host "spotdl failed." -ForegroundColor Red
    Write-Host "Error:`r`n$_" -ForegroundColor Red

    # Cleanup if the command fails
    if (Test-Path -Path $directoryPath) {
        Remove-Item -Path $directoryPath -Recurse -Force
        Write-Host "Removed playlist directory that was created:" -ForegroundColor Yellow
        Write-Host "`t$directoryPath"
    }
    Set-Location -Path $originalPath
    exit
}

# Check if any tracks are missing after the download
if (Test-Path -Path "$infoPath\missing_tracks.txt") {
    $missingTracks = Get-Content "$infoPath\missing_tracks.txt"
    if ($missingTracks.Length -gt 0) {
        Write-Host "`r`nSome tracks were not found." -ForegroundColor Red
        Write-Host "Check the missing tracks in:" -ForegroundColor Red
        Write-Host "`t$infoPath\missing_tracks.txt" 
    } else {
        Write-Host "`r`nAll tracks were successfully downloaded." -ForegroundColor Green
        Remove-Item -Path "$infoPath\missing_tracks.txt" -Force
    }
}

# Return to the original path
Set-Location -Path $originalPath
Write-Host "Playlist '$playlistName' downloaded." -ForegroundColor Green
