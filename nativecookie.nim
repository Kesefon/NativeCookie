#! /bin/env -S nim c -r

import std/strformat
import os
import osproc
import strutils

const NimblePkgVersion {.strdefine.} = "Unknown"
let nativeCookieDir = getAppDir()
let electron = nativeCookieDir / "electron/electron"
let args: seq[string] = commandLineParams()
if args.high() < 1:
    quit(1)
let cmd: string = args[0]
let exe: string = args[1]
var path: string = exe.parentDir()
var exeArgs: seq[string] = newSeq[string](args.high() + 1)
exeArgs[0] = "./resources/app.asar"
exeArgs[1] = "" # reserved for patchArgs()
if args.high > 1:
    exeArgs[2..args.high()] = args[2..args.high()]

proc log(msg: string): void =
    echo("[NativeCookie]", msg)

proc setup(): void =
    log("Setup")

    if fileExists(nativeCookieDir / "greenworks/libsteam_api.so"):
        log("Installing steamworks binaries")
        createDir(path / "resources/app.asar.unpacked/redistributable_bin/linux64/")
        copyFile(nativeCookieDir / "greenworks/libsteam_api.so", path / "resources/app.asar.unpacked/redistributable_bin/linux64/libsteam_api.so",)
    writeFile(path / "nativeCookieVer", NimblePkgVersion)

case cmd
of "run":
    if not exe.endsWith("GeoGuessr.exe"):
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
