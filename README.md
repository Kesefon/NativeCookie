# NativeGuessr
Run GeoGuessr Steam edition with native Electron on Linux.

## Installation

1. Download the latest [release archive](https://github.com/Kesefon/NativeGuessr/releases/latest) and extract it into the `~/.steam/root/compatibilitytools.d/` folder.  
Note: the `compatibilitytools.d` folder might not exist. If that's the case just create it manually.  
You should end up with a structure like this:  
```
~/.steam/root/compatibilitytools.d/nativeguessr/
├── compatibilitytool.vdf
├── electron/
├── greenworks/
├── LICENSE
├── nativecookie
└── toolmanifest.vdf
```
2. Restart Steam.
3. Go into the GeoGuessr properties and set NativeGuessr as the compatibility tool.

## TODO
- This tool is based on [NativeCookie](https://github.com/Kesefon/NativeCookie) and could use some code clean ups. (No problems during usage; just ugly code)
- ~~Long startup time, when launched by steam~~
  - it was the Steam Overlay; disabled for now
- Would be nice to make this more generic for other electron games
  - [Boson](https://github.com/FyraLabs/boson) seems to be doing this
- MacOS support would be cool
