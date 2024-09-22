param (
    [string]$playlistPath
)

if (-not $playlistPath) {
    Write-Host "Usage: .\upd.ps1 <Playlist Path>" -ForegroundColor Magenta
    exit
} elseif (-not (Test-Path -Path $playlistPath)) {
    Write-Host "Playlist directory was not found:" -ForegroundColor Yellow
    Write-Host "`t$playlistPath"
    exit
}

$originalPath = Get-Location
$infoPath = Join-Path $playlistPath ".info"
$syncPath = Join-Path $infoPath "sync.spotdl"

if (-not (Test-Path -Path $syncPath)) {
    Write-Host "No sync file found in the directory:" -ForegroundColor Yellow
    Write-Host "`t$playlistPath"
    exit
}

Set-Location -Path $playlistPath

Write-Host "Syncing playlist:" -ForegroundColor Magenta
Write-Host "`t$playlistPath"
try {
    Invoke-Expression "spotdl sync `"$syncPath`" --sync-without-deleting"
    Write-Host "Playlist synced." -ForegroundColor Magenta
} catch {
    Write-Host "Failed to sync playlist:" -ForegroundColor Red
    Write-Host "`t$playlistPath"
    Write-Host "Error:`r`n$_" -ForegroundColor Red
}
finally {
    Set-Location -Path $originalPath
}
