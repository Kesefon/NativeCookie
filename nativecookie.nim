#! /bin/env -S nim c -r

import std/strformat
import os
import osproc
import strutils
import steamapi

const NimblePkgVersion {.strdefine.} = "Unknown"
let nativeCookieDir = getAppDir()
let electron = nativeCookieDir / "electron/electron"
let args: seq[string] = commandLineParams()
if args.high() < 1:
    quit(1)
let cmd: string = args[0]
let exe: string = args[1]
var path: string = exe.parentDir()
var exeArgs: seq[string] = newSeq[string](args.high())
exeArgs[0] = "./resources/app/"
if args.high > 1:
    exeArgs[1..args.high()-1] = args[2..args.high()]

proc log(msg: string): void =
    echo("[NativeCookie]", msg)

proc setupIcon(): void =
    log("Setup icon")
    let iconPath = path / "resources/app/src/img/icon.ico"
    writeFile(getHomeDir() / "/.local/share/applications/cookie-electron.desktop",&"[Desktop Entry]\nName=Cookie Clicker\nIcon={iconPath}\nNoDisplay=true\nHidden=true")

proc setup(): void =
    log("Setup")

    log("Sub to workshop mod")
    subscribeWorkshopItem(3603591910)

    setupIcon()

    if fileExists(nativeCookieDir / "greenworks/libsteam_api.so"):
        log("Installing greenworks binaries")
        copyFile(nativeCookieDir / "greenworks/greenworks-linux64.node", path / "resources/app/greenworks/lib/greenworks-linux64.node",)
        copyFile(nativeCookieDir / "greenworks/libsdkencryptedappticket.so", path / "resources/app/greenworks/lib/libsdkencryptedappticket.so",)
        copyFile(nativeCookieDir / "greenworks/libsteam_api.so", path / "resources/app/greenworks/lib/libsteam_api.so",)
    writeFile(path / "nativeCookieVer", NimblePkgVersion)

case cmd
of "run":
    if not exe.endsWith("Cookie Clicker.exe"):
        echo("unknown exe: " & exe)
        quit()

    if not fileExists(path / "nativeCookieVer") or readFile(path / "nativeCookieVer") != NimblePkgVersion or existsEnv("forceSetup"):
        setup()

    log("Starting game")
    putEnv("LD_PRELOAD", "")
    discard execProcess(electron, path, exeArgs, options = {poEchoCmd, poParentStreams})
    quit()

of "path":
    echo(args[1])
