import docopt, strutils, rdstdin, options
import stack, op, help, base

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

var
  uiMode = umNormal
  displayedControlModeMsg = false
  mainStack: Stack = @[]

proc setControlMode() =
  uiMode = umControl
  displayedControlModeMsg = false

proc setNormalMode() =
  uiMode = umNormal

proc prompt(): string =
  ## Display the command prompt based on UI Mode.
  case uiMode:
    of umNormal:
      result = "> "
    of umControl:
      if not displayedControlModeMsg:
        echo "Enter 'ok' to return to normal mode."
        displayedControlModeMsg = true
      result = "[control] > "

proc handleControlInput(line: seq[string]) =
  ## Handle line of command input in control mode.
  case line[0]
  of "?", "explain":
    if line.len == 1:
      echo mainStack.explain()
    else:
      let
        token = line[1]
        maybeOperator = getOperator(token)

      if maybeOperator.isSome:
        try:
          let explainStr = maybeOperator.get().explain(mainStack)
          echo explainStr
        except IndexError:
          echo "Invalid context for command: ", token
      else:
        echo "Unknown help input: ", token

  of "hist", "history":
    showHistory()

  of "ok":
    setNormalMode()

  else:
    echo "?"

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

proc handleInput(mode: UiMode, input: string) =
  ## Dispatch on mode to the appropriate handling proc.
  case mode
  of umControl:
    let tokens = input.split()
    handleControlInput(tokens)
  of umNormal:
    case input[0]
    of CONTROL:
      if input.len > 1:
        let
          line = input[1..input.high].strip()
          tokens = line.split()
        handleControlInput(tokens)
      else:
        setControlMode()
    else:
      handleNormalInput(input)

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
        uiMode.handleInput(input)
