# Spotify Playlist Downloader

This repository contains PowerShell scripts to download and manage Spotify playlists using [spotDL](https://github.com/spotDL/spotify-downloader). These scripts allow users to download Spotify playlists and manage missing tracks.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
  - [Download a Playlist](#download-a-playlist)
  - [Update Playlists](#update-playlist)
  - [Update All Playlists](#update-all-playlists)
  - [Update Missing Tracks of Playlist](#update-missing-tracks-of-playlist)
  - [Create xspf file of the Playlist](#create-xspf-file-of-the-playlist)
  - [Create xspf file for All Playlist](#create-xspf-file-for-all-playlist)
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
.\sdl.ps1 <Directory Name> <Spotify URL> [<Optional: Download Path>] [-xspf]
```
- **Directory Name**: The name you want to assign to the downloaded playlist folder.
- **Spotify URL**: The URL of the Spotify playlist.
- **Download Path**: The path where the playlist will be saved. (Optional) A default can be set inside the script.
- **xspf**: (Optional) Include this flag to generate *xspf* file for the playlist. If it was download without missing tracks.

<hr>

### Update Playlist
Run the `upd.ps1` script to update an **already downloaded** playlist:

```bash
.\upd.ps1 <Playlist Path> [-xspf]
```
- **Playlists Path**: The path where the playlist is saved.
- **xspf**: (Optional) Include this flag to generate *xspf* file for the playlist.

<hr>

### Update All Playlists
Run the `updall.ps1` script to update all **already downloaded** playlists:

```bash
.\updall.ps1 [<Optional: Playlists Path>] [-xspf]
```
- **Playlists Path**: The path where the playlists are saved. (Optional) A default can be set inside the script.
- **xspf**: (Optional) Include this flag to generate *xspf* files for the playlists.

<hr>

### Update Missing Tracks of Playlist

Run the `mpd.ps1` script to update the missing tracks of an **already downloaded** playlist:

```bash
.\mpd.ps1 <Playlist Path> [-xspf]
```
- **Playlists Path**: The path where the playlist is saved.
- **xspf**: (Optional) Include this flag to generate *xspf* files for the playlists.

<hr>

### Create xspf File of the Playlist

Run the `xspf.ps1` script to create a *xspf* file of an **already downloaded** playlist:

```bash
.\xspf.ps1 <Playlist Path> 
```
- **Playlists Path**: The path where the playlist is saved.

### Create xspf File for All Playlist

Run the `xspfall.ps1` script to create a *xspf* file for all  **already downloaded** playlists:

```bash
.\xspfall.ps1 [<Optional: Playlists Path>]
```
- **Playlists Path**: The path where the playlists are saved. (Optional) A default can be set inside the script.

<hr>

## Missing Tracks

If a track is not found during the download process, the `missing_tracks.txt` file will contain the relevant information. 

Possible errors on the file:
- If you see this one follow the [missing_tracks_example.txt](missing_tracks_example.txt) 
```
https://open.spotify.com/track/4PTG3Z6ehGkBFwjybzWkR8?si=5413617837db457d - LookupError: No results found for song: 'Artist' - 'Music Name'
```
- For this one it downloaded the music but failed to download the metadata. Delete the music without metadata and run [upd.ps1](#update-playlist) if you what to retry download with the metadata. You can delete this line from the `missing_tracks.txt` and if it ends up empty you can delete the file.
```
https://open.spotify.com/track/4PTG3Z6ehGkBFwjybzWkR8?si=5413617837db457d - MetadataError: Failed to embed metadata to the song
```

## Known Issues
- If the commad freezes it's probably problems with communication with the spotify api. To solve the problem check the solution for the problem below.
- For 429/500/404 Errors and Rate Limiting Issues, you can see the details [here](https://github.com/spotDL/spotify-downloader/issues/2142).

## License

This project is licensed under the [MIT License](LICENSE).