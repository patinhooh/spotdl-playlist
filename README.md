# Spotify Playlist Downloader

This repository contains PowerShell scripts to download and manage Spotify playlists using spotdl. The scripts allow users to download playlists from Spotify and update them with missing tracks.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
  - [Download a Playlist](#download-a-playlist)
  - [Update Playlists](#update-playlists)
- [Example of Missing Tracks](#example-of-missing-tracks)
- [Contributing](#contributing)
- [License](#license)

## Installation

1. Ensure you have PowerShell installed on your system.
2. Install [spotdl](https://github.com/spotDL/spotify-downloader#installation) according to its instructions.
3. Clone this repository:
```bash
   git clone https://github.com/patinhooh/spotdl-playlist.git
   cd spotdl-playlist
```

## Usage

### Download a Playlist

Run the sdl.ps1 script to download a Spotify playlist:
```bash
.\sdl.ps1 <Directory Name> <Spotify URL> [<Optional: Download Path>]
```
- Directory Name: The name you want to assign to the downloaded playlist folder.
- Spotify URL: The URL of the Spotify playlist.
- Download Path: (Optional) The path where the playlist will be saved. Set the default inside the script.

### Update Playlists

`Note`: This feature is still under development.

## Example of Missing Tracks

If a track is not found during the download process, the missing_tracks.txt file will contain the info. See [missing_tracks_example.txt](missing_track_example.txt) for more detail.

## License

This project is licensed under the [MIT License](LICENSE).