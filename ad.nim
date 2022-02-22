import strutils, rdstdin, os
import src/obj, src/stack

const
  prompt = "> "
  doc = """
Simple Reverse Polish Calculator.

Usage:
  ad [<exp>...]

If passed any arguments, ad will interpret
them as a series of commands. Otherwise it
will enter interactive mode, where you can
use it as a shell for running calculations.
"""
proc handleArgs(args: var seq[string]) =
  ## Arg handling and special cases.
  # Handle quoted expressions
  if args.len == 1 and ' ' in args[0]:
    args = args[0].split(" ")
  if "-h" in args or "--help" in args:
    echo doc
    quit()
  if "-v" in args or "--version" in args:
    echo "ad " & "0.6.4"
    quit()

var mainStack: Stack = @[]

proc handleInput(input: string) =
  ## Handle a line of input in normal mode.
  let tokens = input.split()
  var oldStack = mainStack

  try:
    mainStack.ingestLine(tokens)
  except ValueError:
    mainStack = oldStack
    echo getCurrentExceptionMsg()

proc main() =
  # Parse arguments
  var args = commandLineParams()
  handleArgs(args)

  defer: mainStack.displaySummary()

  # Read input from command line or interactive mode.
  if args.len > 0:
    try:
      mainStack.ingestLine(args)
    except ValueError:
      echo getCurrentExceptionMsg()

  else:
    var input: string

    while true:
      try:
        input = readLineFromStdin(prompt)
      except IOError:
        break

      input = input.strip()

      if input.len > 0:
        handleInput(input)

when isMainModule:
  main()
