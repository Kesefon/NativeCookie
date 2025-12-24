# Package

version       = staticExec("git describe --long --abbrev=7 --tags | sed 's/^v//;s/-/.r/;s/-/./'")
author        = "Kesefon"
description   = "Run Cookie Clicker with native electron."
license       = "MIT"
srcDir        = "."
bin           = @["nativecookie"]
backend       = "cpp"


# Dependencies

requires "nim >= 1.4.8"
