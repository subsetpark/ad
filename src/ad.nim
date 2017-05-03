import docopt, strutils, rdstdin, options
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

var
  displayedControlModeMsg = false
  mainStack: Stack = @[]

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
  # Read input from command line or interactive mode.
  let args = docopt(doc, version=VERSION)
  defer: mainStack.handleExit()

  if args["<exp>"]:
    try:
      mainStack.ingestLine(@(args["<exp>"]))
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
