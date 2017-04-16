# Package
version       = "0.2"
author        = "Z. D. Smith"
description   = "A simple RPN calculator"
license       = "MIT"
bin           = @["ad"]
srcDir        = "src"
binDir        = "bin"
skipExt       = @["nim"]

# Deps
requires "nim >= 0.14.2"
requires "docopt >= 0.1.0"
