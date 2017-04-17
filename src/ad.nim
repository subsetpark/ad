import docopt, strutils, future, sequtils, math, rdstdin, options
import stack, op, help

type UiMode = enum
  umNormal, umControl

const
  CONTROL = ';'
  doc = """
Simple Reverse Polish Calculator.

Usage:
  ad [<exp>...]

If passed any arguments, ad will interpret
them as a series of commands. Otherwise it
will enter interactive mode, where you can
use it as a shell for running calculations.
"""

let args = docopt(doc, version="AD 1")

var
  uiMode = umNormal
  displayedControlModeMsg = false
  mainStack: Stack = @[]

proc prompt(): string =
  case uiMode:
    of umNormal:
      result = "> "
    of umControl:
      if not displayedControlModeMsg:
        echo "Enter 'ok' to return to normal mode."
        displayedControlModeMsg = true
      result = "[control] > "

proc handleCommand(stack: Stack, args: seq[string]) =
  case args[0]
  of "?":
    if args.len == 1:
      echo stack.explain()
    else:
      let token = args[1]

      let maybeOperator = getOperator(token)
      if maybeOperator.isSome:
        try:
          let explainStr = maybeOperator.get().explain(stack)
          echo explainStr
        except IndexError:
          echo "Invalid context for command: ", token
      else:
        echo "Unknown help input: ", token

  of "ok":
    uiMode = umNormal

  else: discard

proc handleNormalInput(input: string) =
  try:
    mainStack.ingestLine(input)
  except IndexError:
    echo "Not enough stack."
  except ValueError:
    echo getCurrentExceptionMsg()

proc enterControlMode(input: string) =
  if input.len > 1:
    let
      line = input[1..input.high].strip()
      tokens = line.split()
    mainStack.handleCommand(tokens)
  elif uiMode != umControl:
    uiMode = umControl
    displayedControlModeMsg = false

proc handleControlInput(input: string) =
  let tokens = input.split()

  mainStack.handleCommand(tokens)

if args["<exp>"]:
  try:
    mainStack.ingestLine(@(args["<exp>"]))
  except IndexError:
    quit("Imbalanced input.")
  except ValueError:
    echo getCurrentExceptionMsg()

  if mainStack.len > 0:
    mainStack.peek()
  if mainStack.len > 1:
    echo "Stack remaining:"
    mainStack[..(mainStack.high-1)].show()

else:
  while true:
    let input = readLineFromStdin(prompt()).strip()
    if input.len > 0:
      case uiMode:
        of umNormal:
          if input[0] == CONTROL:
            enterControlMode(input)
          else:
            handleNormalInput(input)
        of umControl:
          handleControlInput(input)
