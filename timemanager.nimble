# Package

version       = "0.1.0"
author        = "nirokay"
description   = "A webserver to coordinate times where people are free."
license       = "GPL-3.0-only"
srcDir        = "src"
bin           = @["server"]


# Dependencies

requires "nim >= 1.6.20"
requires "websitegenerator", "https://github.com/nirokay/db_connector"
