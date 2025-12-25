#! /bin/env -S nim c -r

import std/strformat
import os
import osproc
import strutils
import steamapi

const NimblePkgVersion {.strdefine.} = "Unknown"
let nativeCookieDir = getAppDir()
let electron = if fileExists(nativeCookieDir / "electron/cookie-electron"):
    nativeCookieDir / "electron/cookie-electron" # workaround for https://github.com/electron/electron/issues/27581
    else: nativeCookieDir / "electron/electron"
let args: seq[string] = commandLineParams()
if args.high() < 1:
    quit(1)
let cmd: string = args[0]
let exe: string = args[1]
var path: string = exe.parentDir()
var exeArgs: seq[string] = newSeq[string](args.high() + 1)
exeArgs[0] = "./resources/app/"
exeArgs[1] = "" # reserved for patchArgs()
if args.high > 1:
    exeArgs[2..args.high()] = args[2..args.high()]

proc log(msg: string): void =
    echo("[NativeCookie]", msg)

proc setupIcon(): void =
    log("Setup icon")
    let iconPath = path / "resources/app/src/img/icon.png"
    if execCmd(&"xdg-icon-resource install --size 512 '{iconPath}' cookie-electron") != 0:
        log("xdg-icon-resource: failed to install icon; is xdg-utils installed?")
    if execCmd(&"xdg-desktop-menu install '{nativeCookieDir}/cookie-electron.desktop'") != 0:
        log("xdg-desktop-menu: failed to install desktop-file; is xdg-utils installed?")

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

proc patchArgs(): void =
    # workaround for https://github.com/electron/electron/issues/27581
    log("Patch args")
    var i = exeArgs.high()
    while i > 1:
        if exeArgs[i].startsWith("--disable-features=") or exeArgs[i].startsWith("-disable-features="):
            exeArgs[i] = exeArgs[i] & ",AudioServiceOutOfProcess"
            break
        dec i
        if i==1:
            exeArgs[1] = "--disable-features=AudioServiceOutOfProcess"

case cmd
of "run":
    if not exe.endsWith("Cookie Clicker.exe"):
        echo("unknown exe: " & exe)
        quit()

    if not fileExists(path / "nativeCookieVer") or readFile(path / "nativeCookieVer") != NimblePkgVersion or existsEnv("forceSetup"):
        setup()

    patchArgs()

    log("Starting game")
    putEnv("LD_PRELOAD", "")
    discard execProcess(electron, path, exeArgs, options = {poEchoCmd, poParentStreams})
    quit()

of "path":
    echo(args[1])
