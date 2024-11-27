param (
    [switch]$xspf,        # A flag parameter for creating XSPF files
    [string]$playlistPath
)

if (-not $playlistPath) {
    Write-Host "Usage: .\upd.ps1 <Playlist Path> [-xspf]" -ForegroundColor Magenta
    exit
} elseif (-not (Test-Path -Path $playlistPath)) {
    Write-Host "Playlist directory was not found:" -ForegroundColor Yellow
    Write-Host "    '$playlistPath'"
    exit
}

$originalPath = Get-Location
$playlistPath = $playlistPath | Resolve-Path
$playlistPath = $playlistPath -replace "'","`'"
$infoPath = Join-Path $playlistPath ".info"
$syncPath = Join-Path $infoPath "sync.spotdl"
$umtScript = Join-Path $originalPath  "umt.ps1"
$xspfScript = Join-Path $originalPath  "xspf.ps1"
$missingTracksExisted = Test-Path -Path "$infoPath\missing_tracks.txt"

if (-not (Test-Path -Path $syncPath)) {
    Write-Host "No sync file found in the directory:" -ForegroundColor Yellow
    Write-Host "    '$playlistPath'"
    exit
}

Write-Host "Syncing playlist:" -ForegroundColor Magenta
Write-Host "    '$playlistPath'"

# Update Playlist
Set-Location -Path $playlistPath
try {
    #--sync-without-deleting ?
    if ($missingTracksExisted){
        Invoke-Expression "spotdl sync `"$syncPath`" --save-errors '$infoPath\missing_tracks_upd.txt'"
    }else{
        Invoke-Expression "spotdl sync `"$syncPath`" --save-errors '$infoPath\missing_tracks.txt'"
    }
    Write-Host "spotdl finished.`r`n" -ForegroundColor Magenta
} catch {
    Write-Host "Failed to sync playlist:" -ForegroundColor Red
    Write-Host "    '$playlistPath'"
    Write-Host "Error:`r`n$_" -ForegroundColor Red
}

# Manually added tracks 
try {
    & $umtScript -playlistPath $playlistPath
} catch {
    Write-Host "Error occurred while running umt.ps1:" -ForegroundColor Red
    Write-Host "`r`n$_" -ForegroundColor Red
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

# Missing Tracks
$missingTracks = Get-Content -Path "$infoPath\missing_tracks.txt"
if ($missingTracksExisted){
    # Append new Errors
    $updatedTracks = Get-Content -Path "$infoPath\missing_tracks_upd.txt"

    if ($updatedTracks.Count -gt 0){
        $spotifyLinksInMissingTracks = $missingTracks | ForEach-Object {
            if ($_ -match "https://open\.spotify\.com/track/\S+") {
                $matches[0]
            }
        }
    
        $newLines = $updatedTracks | Where-Object {
            if ($_ -match "https://open\.spotify\.com/track/\S+"){
                $spotifyLink = $matches[0]
            }
            else {
                $spotifyLink = $null
            }
            $spotifyLink -and $spotifyLink -notin $spotifyLinksInMissingTracks
        }
    
        if ($newLines.Count -gt 0) {
            foreach ($line in $newLines) {
                Add-Content -Path "$infoPath\missing_tracks.txt" -Value "`r`n$line"
            }
            Write-Host "`r`nSome new tracks were not found." -ForegroundColor Yellow
            Write-Host "Check the missing tracks in:" -ForegroundColor Yellow
            Write-Host "    '$infoPath\missing_tracks.txt'" 
        }
    }
    Remove-Item -Path "$infoPath\missing_tracks_upd.txt" -Force
}else{
    # Commad created a new missing_tracks.txt
    if ($missingTracks.Length -gt 0) {
        Write-Host "`r`nSome tracks were not found." -ForegroundColor Yellow
        Write-Host "Check the missing tracks in:" -ForegroundColor Yellow
        Write-Host "    '$infoPath\missing_tracks.txt'" 
    }
}
Write-Host ""
Set-Location -Path $originalPath