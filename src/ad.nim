import strutils, rdstdin, options, os
import stack, op, base

const
  doc = """
Simple Reverse Polish Calculator.

Usage:
  ad [<exp>...]

If passed any arguments, ad will interpret
them as a series of commands. Otherwise it
will enter interactive mode, where you can
use it as a shell for running calculations.
"""

var mainStack: Stack = @[]

proc prompt(): string = "> "

proc handleNormalInput(input: string) =
  ## Handle a line of input in normal mode.
  let tokens = input.split()
  var oldStack = mainStack
  try:
    mainStack.ingestLine(tokens)
  except IndexError:
    mainStack = oldStack
    echo "Not enough stack."
  except ValueError:
    mainStack = oldStack
    echo getCurrentExceptionMsg()

when isMainModule:
  # Parse arguments
  var args = commandLineParams()
  # Handle quoted expressions
  if args.len == 1 and ' ' in args[0]:
    args = args[0].split(" ")
  if "-h" in args or "--help" in args:
    echo doc
    quit()
  if "-v" in args or "--version" in args:
    echo "ad " & VERSION
    quit()
  defer: mainStack.handleExit()

  # Read input from command line or interactive mode.
  if args.len > 0:
    try:
      mainStack.ingestLine(args)
    except IndexError:
      quit("Imbalanced input.")
    except ValueError:
      echo getCurrentExceptionMsg()

  else:
    var input: string
    while true:
      try:
        input = readLineFromStdin(prompt())
      except IOError:
        break

      input = input.strip()
      if input.len > 0:
        handleNormalInput(input)
