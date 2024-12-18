param (
    [string]$playlistPath,
    [switch]$abs
)

# Check if the playlist path is provided
if (-not $playlistPath) {
    Write-Host "Usage: .\xspf.ps1 <Playlist Path> [-abs]" -ForegroundColor Magenta
    exit
} elseif (-not (Test-Path -Path $playlistPath)) {
    Write-Host "Playlist directory was not found:" -ForegroundColor Yellow
    Write-Host "    '$playlistPath'"
    exit
}

$playlistPath = $playlistPath | Resolve-Path
# Sanitize folder name to create a valid file name
$folderName = Split-Path $playlistPath -Leaf 
$fileName = $folderName -replace ' ', '-'`
                        -replace '[^a-zA-Z0-9-]', ''`
                        -replace '--', ''`
                        -replace '^-', ''`
                        -replace '-$', ''

$fileName = $fileName.ToLower()

# Define the output path for the XSPF file
$infoDir = Join-Path $playlistPath ".info"
if (-not (Test-Path -Path $infoDir)) {
    Write-Host "Playlist .info directory was not found:" -ForegroundColor Red
    Write-Host "    '$infoDir'"
    exit
}

$xspfPath = Join-Path $infoDir "$fileName.xspf"

# Get all track files in the playlist path
$trackFiles = Get-ChildItem -Path $playlistPath -File
if ($trackFiles.Count -eq 0) {
    Write-Host "No track files found in the specified playlist path." -ForegroundColor Yellow
    exit
}

$xspfContent = @"
<?xml version="1.0" encoding="UTF-8"?>
<playlist version="1" xmlns="http://xspf.org/ns/0/" xmlns:vlc="http://www.videolan.org/vlc/playlist/ns/0/">
  <title>$folderName</title>
  <trackList>
"@

foreach ($track in $trackFiles) {
    # Convert the file path to a URI
	if ($abs) {
		$escapedPath = [System.Uri]::EscapeDataString($track.FullName)
		$uri = "file:///$escapedPath" -replace "%5C", "/" -replace "&", "&amp;"
	} else {
		$escapedName = [System.Uri]::EscapeDataString($track.Name)
		$uri = "../$escapedName" -replace "%5C", "/" -replace "&", "&amp;"
	}

    $xspfContent += @"

    <track>
        <location>$uri</location>
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