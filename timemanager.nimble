# Package

version       = "1.0.0"
author        = "nirokay"
description   = "A webserver to coordinate times when people are free."
license       = "GPL-3.0-only"
srcDir        = "src"
bin           = @["server"]


# Tasks

task compilerun, "Compiles TS and Nim and runs the server":
    echo "Compiling TypeScript..."
    exec "tsc"

    echo "Compiling Nim..."
    exec "nimble run"


# Dependencies

requires "nim >= 2.0.0"
requires "db_connector"
requires "https://github.com/nirokay/CatTag == 0.1.3"
