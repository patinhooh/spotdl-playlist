param (
    [switch]$xspf,        # A flag parameter for creating XSPF files
    [string]$playlistPath
)

if (-not $playlistPath) {
    Write-Host "Usage: .\upd.ps1 <Playlist Path> [-xspf]" -ForegroundColor Magenta
    exit
} elseif (-not (Test-Path -Path $playlistPath)) {
    Write-Host "Playlist directory was not found:" -ForegroundColor Yellow
    Write-Host "`t$playlistPath"
    exit
}

$originalPath = Get-Location
$infoPath = Join-Path $playlistPath ".info"
$syncPath = Join-Path $infoPath "sync.spotdl"
$mpdScript = Join-Path $originalPath  "mpd.ps1"
$xspfScript = Join-Path $originalPath  "xspf.ps1"

if (-not (Test-Path -Path $syncPath)) {
    Write-Host "No sync file found in the directory:" -ForegroundColor Yellow
    Write-Host "`t$playlistPath"
    exit
}

Write-Host "Syncing playlist:" -ForegroundColor Magenta
Write-Host "`t$playlistPath"

# Update Playlist
Set-Location -Path $playlistPath
try {
    Invoke-Expression "spotdl sync `"$syncPath`" --sync-without-deleting"
    Write-Host "Playlist synced." -ForegroundColor Magenta
} catch {
    Write-Host "Failed to sync playlist:" -ForegroundColor Red
    Write-Host "`t$playlistPath"
    Write-Host "Error:`r`n$_" -ForegroundColor Red
}

# Manually added tracks 
try {
    & $mpdScript -playlistPath $playlistPath
} catch {
    Write-Host "Error occurred while running mpd.ps1:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
} 

# Create xspf file for playlist
if($xspf){
    try {
        & $xspfScript -playlistPath $playlistPath
    } catch {
        Write-Host "Error occurred while running xspf.ps1:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    } 
}

Set-Location -Path $originalPath
