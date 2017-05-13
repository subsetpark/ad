import src.base
# Package
version       = VERSION
author        = "Z. D. Smith"
description   = "A simple RPN calculator"
license       = "MIT"
bin           = @["ad"]
srcDir        = "src"
binDir        = "bin"
skipExt       = @["nim"]

# Deps
requires "nim >= 0.14.2"
