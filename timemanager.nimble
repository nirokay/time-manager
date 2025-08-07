# Package

version       = "0.1.0"
author        = "nirokay"
description   = "A webserver to coordinate times where people are free."
license       = "GPL-3.0-only"
srcDir        = "src"
bin           = @["server"]


# Dependencies

requires "nim >= 2.0.0"
requires "https://github.com/nirokay/CatTag == 0.1.1", "https://github.com/nirokay/db_connector"
