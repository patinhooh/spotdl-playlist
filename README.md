# Spotify Playlist Downloader

This repository contains PowerShell scripts to download and manage Spotify playlists using [spotDL](https://github.com/spotDL/spotify-downloader). These scripts allow users to download Spotify playlists and manage missing tracks.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
  - [Download a Playlist](#download-a-playlist)
  - [Update Playlists](#update-playlists)
  - [Update Missing Tracks of Playlist](#update-missing-tracks-of-playlist)
- [Missing Tracks](#missing-tracks)
- [Known Issues](#known-issues)
- [License](#license)

## Installation

1. Ensure you have PowerShell installed on your system.
2. Install [spotDL](https://github.com/spotDL/spotify-downloader#installation) according to its instructions.
3. Clone this repository:
    ```bash
    git clone https://github.com/patinhooh/spotdl-playlist.git
    cd spotdl-playlist
    ```

## Usage

### Download a Playlist

Run the `sdl.ps1` script to download a Spotify playlist:

```bash
.\sdl.ps1 <Directory Name> <Spotify URL> [<Optional: Download Path>]
```
- **Directory Name**: The name you want to assign to the downloaded playlist folder.
- **Spotify URL**: The URL of the Spotify playlist.
- **Download Path**: The path where the playlist will be saved. (Optional) A default can be set inside the script.

### Update Playlists
Run the `upd.ps1` script to update all **already downloaded** playlist:

```bash
.\upd.ps1 [<Optional: Playlists Path>] [-xspf]
```
- **Playlists Path**: The path where the playlists are saved. (Optional) A default can be set inside the script.
- **xspf**: (Optional) Include this flag to generate XSPF files for the playlists.

### Update Missing Tracks of Playlist

Run the `mpd.ps1` script to update the missing tracks of an **already downloaded** playlist:

```bash
.\mpd.ps1 <Playlist Path> 
```
- **Playlists Path**: The path where the playlist is saved.

## Missing Tracks

If a track is not found during the download process, the `missing_tracks.txt` file will contain the relevant information. For more details, check the [missing_tracks_example.txt](missing_tracks_example.txt) file in the repository.

## Known Issues

- For 429/500/404 Errors and Rate Limiting Issues, you can see the details [here](https://github.com/spotDL/spotify-downloader/issues/2142).

## License

This project is licensed under the [MIT License](LICENSE).