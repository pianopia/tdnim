# Package

version       = "0.1.0"
author        = "shota.nakagawa"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir        = "src"
bin           = @["tdnim"]



# Dependencies

requires "nim >= 1.0.0"
requires "docopt"
requires "nimSHA2"

task hello, "This is a hello task":
  echo("Hello World!")
