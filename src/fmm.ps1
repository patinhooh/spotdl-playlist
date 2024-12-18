param (
    [switch]$add,
    [string]$playlistPath,
    [string]$trackName,
    [string]$correctSrcURL
)
# Convert to Full Path
$playlistPath = $playlistPath | Resolve-Path

if (-not $playlistPath){
    Write-Host "To add track to the miss matches" -ForegroundColor Yellow
    Write-Host "Usage: .\fmm.ps1 -add <Playlist Path> <Track File Name> <Correct Source URL> " -ForegroundColor Magenta
    Write-Host "or " -ForegroundColor Yellow
    Write-Host "To fix the miss matches tracks" -ForegroundColor Yellow
    Write-Host "Usage: .\fmm.ps1 <Playlist Path> " -ForegroundColor Magenta
    exit
}

$originalPath = Get-Location
$mismatchedFile = Join-Path $playlistPath ".info\mismatch_tracks.txt"


if ($add){
    if (-not $trackName -or -not $correctSrcURL){
        Write-Host "To add track to the miss matches" -ForegroundColor Yellow
        Write-Host "Usage: .\fmm.ps1 -add <Playlist Path>  <Track File Name> <Correct Source URL> " -ForegroundColor Magenta
        Write-Host "or " -ForegroundColor Magenta
        Write-Host "To fix the miss matches tracks" -ForegroundColor Yellow
        Write-Host "Usage: .\fmm.ps1 <Playlist Path> " -ForegroundColor Magenta
        exit
    }

    

    if (-not (Test-Path -Path $mismatchedFile)) {
        Set-Content -Path $mismatchedFile -Value "$trackName|$correctSrcURL"
    } else {
        # TODO: Make Something better in the case of change in source for a music
        $conflict = Get-Content -Path $mismatchedFile | Where-Object { $_ -match "$trackName" }
        if ($conflict.Count -gt 0){
            Write-Host "$trackName already is in the file." -ForegroundColor Red
            exit
        }

        Add-Content -Path $mismatchedFile -Value "$trackName|$correctSrcURL"
    }
    
    Write-Host "Logged $trackName as mismatched and saved correct URL." -ForegroundColor Green
    exit
}

# Update the Miss Matches


if (-not (Test-Path -Path $mismatchedFile)) {
    Write-Host "No miss matches added yet." -ForegroundColor Yellow
    Write-Host "To add track to the miss matches" -ForegroundColor Magenta
    Write-Host "`t.\fmm.ps1 -add <Playlist Path> <Track File Name> <Correct URL> " -ForegroundColor Magenta
    exit
} 

$mismatchedTracks = Get-Content -Path $mismatchedFile
if ($mismatchedTracks.Count -eq 0){
    Write-Host "No miss matches added yet." -ForegroundColor Yellow
    Write-Host "To add track to the miss matches" -ForegroundColor Magenta
    Write-Host "`t.\fmm.ps1 -add <Playlist Path> <Track File Name> <Correct URL> " -ForegroundColor Magenta
    exit
}
# Update Playlist
Set-Location -Path $playlistPath
foreach ($track in $mismatchedTracks) {

    # TODO: This can Explode if the lines where edited more then they needed
    $splitLine = $track -split "\|"
    $trackMisMatch = $splitLine[0]
    $trackCorrectURL = $splitLine[1]
    
    $trackPath = Join-Path $playlistPath $trackMisMatch
    Write-Host "Miss matched track:" -ForegroundColor Blue
    Write-Host "`t$trackMisMatch" 
    
    # Delete the miss matched track
    if (Test-Path $trackPath) {
        Remove-Item $trackPath
        Write-Host "Deleted mismatched track." -ForegroundColor Green
    } else {
        Write-Host "No Track found to delete." -ForegroundColor Yellow
    }


    $trackNameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($trackMisMatch)

    Write-Host "Downloading correct track." -ForegroundColor Green
    try {
        Write-Host "spotdl `"$trackCorrectURL`" --output `"$trackNameWithoutExtension.{output-ext}`"" -ForegroundColor Magenta
        Invoke-Expression "spotdl `"$trackCorrectURL`" --output `"$trackNameWithoutExtension.{output-ext}`""
    } catch {
        Write-Host "Failed to download music." -ForegroundColor Red
        Write-Host "Error:`r`n$_" -ForegroundColor Red
    }
}

Write-Host ""
Set-Location -Path $originalPath