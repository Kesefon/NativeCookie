# NativeCookie
Run Cookie Clicker Steam edition with native Electron on Linux.

## Installation
1. Download the latest [release archive](https://github.com/Kesefon/NativeCookie/releases/latest) and extract it into the `~/.steam/root/compatibilitytools.d/` folder.  
You should end up with a structure like this:  
```
~/.steam/root/compatibilitytools.d/nativecookie/
├── compatibilitytool.vdf
├── icon_patch.diff
├── LICENSE
├── nativecookie
└── toolmanifest.vdf
```
2. Restart Steam.
3. Go into the Cookie Clicker properties and set NativeCookie as the compatibility tool.

## TODO
- ~~Long startup time, when launched by steam~~
  - it was the Steam Overlay; disabled for now
- Would be nice to make this more generic for other electron games
  - [Boson](https://github.com/FyraLabs/boson) seems to be doing this
- MacOS support would be cool
