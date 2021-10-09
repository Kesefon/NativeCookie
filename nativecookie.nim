#! /bin/env -S nim c -r 

import os
import osproc
import strutils

let args: seq[string] = commandLineParams()
echo(args)
if args.high() < 1:
    quit(1)
let cmd: string = args[0]
let exe: string = args[1]
var path: string = exe.parentDir()
var exeArgs: seq[string] = newSeq[string](args.high())
exeArgs[0] = "./resources/app/"
if args.high > 1:
    exeArgs[1..args.high()-1] = args[2..args.high()]

case cmd
of "run":
    if exe.endsWith("iscriptevaluator.exe"):
        quit()
    
    discard execProcess("electron", path, exeArgs, options={poUsePath})

sleep(10)