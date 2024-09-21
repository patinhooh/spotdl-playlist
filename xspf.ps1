param (
    [string]$playlistPath
)

$folderName = Split-Path $playlistPath -Leaf 
$fileFormatName = ($folderName -replace ' ', '-' -replace '[^a-zA-Z0-9-]', '').ToLower()
$xspfFilePath = Join-Path $playlistPath ".info\$fileFormatName.xspf"

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
    $uri = [System.Uri]::EscapeUriString("file:///$($track.FullName)")
    $xspfContent += @"
<track>
  <location>$uri</location>
  <title>$($track.Name)</title>
</track>
"@
}

$xspfContent += @"
  </trackList>
</playlist>
"@

# Save the XSPF content to a file
try {
    Set-Content -Path $xspfFilePath -Value $xspfContent -Encoding UTF8 -ErrorAction Stop
    Write-Host "XSPF file created at:" -ForegroundColor Green
    Write-Host "`t$xspfFilePath"
} catch {
    Write-Host "Failed to create XSPF file:" -ForegroundColor Red
    Write-Host "`t$xspfFilePath"
    Write-Host "Error:`r`n$_" -ForegroundColor Red
}