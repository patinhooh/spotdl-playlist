param (
    [string]$playlistPath
)

if (-not $playlistPath) {
    Write-Host "Usage: .\xspf.ps1 <Playlist Path>" -ForegroundColor Magenta
    exit
} elseif (-not (Test-Path -Path $playlistPath)) {
    Write-Host "Playlist directory was not found:" -ForegroundColor Yellow
    Write-Host "    '$playlistPath'"
    exit
}

$folderName = Split-Path $playlistPath -Leaf 
$fileName = ($folderName -replace ' ', '-' -replace '[^a-zA-Z0-9-]', '').ToLower()
$xspfPath = Join-Path $playlistPath ".info\$fileName.xspf"

# Get all track files in the playlist path
$trackFiles = Get-ChildItem -Path $playlistPath -File
if ($trackFiles.Count -eq 0) {
    Write-Host "No track files found in the specified playlist path." -ForegroundColor Yellow
    exit
}

# Initialize the XSPF content
$xspfContent = @"
<?xml version="1.0" encoding="UTF-8"?>
<playlist version="1" xmlns="http://xspf.org/ns/0/" xmlns:vlc="http://www.videolan.org/vlc/playlist/ns/0/">
  <title>$folderName</title>
  <trackList>`r`n
"@

foreach ($track in $trackFiles) {
    # Convert the file path to a URI
    # TODO: Make it better
    $uri = ([System.Uri]::EscapeUriString("file:///$($track.FullName)")) -replace "%5C", "/" -replace "&", "&amp;"
    $xspfContent += @"
    <track>
    <location>$uri</location>
    <title>$($track.Name -replace "&", "&amp;")</title>
    </track>
"@
}

$xspfContent += @"
    </trackList>
</playlist>
"@

# Save the XSPF content to a file
try {
    Set-Content -Path $xspfPath -Value $xspfContent -Encoding UTF8 -ErrorAction Stop
    Write-Host "XSPF file created at:" -ForegroundColor Green
    Write-Host "    '$xspfPath'"
} catch {
    Write-Host "Failed to create XSPF file:" -ForegroundColor Red
    Write-Host "    '$xspfPath'"
    Write-Host "Error:`r`n$_" -ForegroundColor Red
}
Write-Host ""