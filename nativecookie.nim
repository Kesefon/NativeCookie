#! /bin/env -S nim c -r

import os
import osproc
import strutils
import httpClient
import zippy/ziparchives

const nativeCookieVersion = "1"
const electronAbi = "98"
const electronBuild = "https://github.com/electron/electron/releases/download/v15.1.2/electron-v15.1.2-linux-x64.zip"
var electron: string
let nativeCookieDir = getAppDir()
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

when fileExists(currentSourcePath.parentDir() / "greenworks/greenworks-linux64.node") and
    fileExists(currentSourcePath.parentDir() / "greenworks/libsdkencryptedappticket.so") and
    fileExists(currentSourcePath.parentDir() / "greenworks/libsteam_api.so"):
    const steamLibs: array[3, string] =
        [staticRead(currentSourcePath.parentDir() / "greenworks/greenworks-linux64.node"),
         staticRead(currentSourcePath.parentDir() / "greenworks/libsdkencryptedappticket.so"),
         staticRead(currentSourcePath.parentDir() / "greenworks/libsteam_api.so")]
else:
    const steamLibs = nil

proc downloadElectron(): void =
    let electronZip = getTempDir() / "nativeCookieElectron.zip"
    let httpClient = newHttpClient()
    httpClient.downloadFile(electronBuild, electronZip)
    extractAll(electronZip, nativeCookieDir / "electron")

proc findElectron(): string =
    if existsEnv("electronBin"):
        log("Using custom electron")
        result = getEnv("electronBin")
        return

    if existsEnv("forceDownload"):
        log("Forced download")
        removeDir(nativeCookieDir / "electron/")
        downloadElectron()
        result = nativeCookieDir / "electron/electron"
        return

    result = findExe("electron15")
    if result == "":
        result = findExe("electron")
        if result == "" or execProcess(result, args = ["-a"]) != electronAbi:
            if fileExists(nativeCookieDir / "electron/electron"):
                result = nativeCookieDir / "electron/electron"
            else:
                log("""No compatible electron executable found!
                Downloading one now""")
                downloadElectron()
                result = nativeCookieDir / "electron/electron"

proc setup(): void =
    log("Setup")
    log("Patch icon")
    if 0 != execShellCmd("patch -f --binary -i \"" & nativeCookieDir /
            "icon_patch.diff" & "\" \"" & path / "resources/app/start.js" & "\""):
        log("Failed!")
    log("Searching/Downloading electron")
    electron = findElectron()
    log("Found: " & electron)
    when declared(steamLibs):
        if not existsEnv("disableSteamLibs"):
            log("Installing greenworks binaries")
            writeFile(path / "resources/app/greenworks/lib/greenworks-linux64.node",
                    steamLibs[0])
            writeFile(path / "resources/app/greenworks/lib/libsdkencryptedappticket.so",
                    steamLibs[1])
            writeFile(path / "resources/app/greenworks/lib/libsteam_api.so",
                    steamLibs[2])
    writeFile(path / "nativeCookieVer", nativeCookieVersion)

case cmd
of "run":
    if not exe.endsWith("Cookie Clicker.exe"):
        quit()

    if not fileExists(path / "nativeCookieVer") or existsEnv("forceSetup"):
        setup()

    log("Starting game")
    quit(execProcess(electron, path, exeArgs, options = {poUsePath}))

of "path":
    echo(args[1])
