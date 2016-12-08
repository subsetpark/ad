import docopt, strutils, future, sequtils, stack, op, math

when defined(testing):
  include tests
  quit()
# === Main operation ===
when isMainModule:
  const doc = """
  Simple Reverse Polish Calculator.

  Usage:
    ad [<exp>...]

  If passed any arguments, ad will interpret
  them as a series of commands. Otherwise it 
  will enter interactive mode, where you can 
  use it as a shell for running calculations.
  """

  let args = docopt(doc, version="AD 1")
  var mainStack: Stack = @[]
  if args["<exp>"]:
    try:
      mainStack = mainStack.ingestLine(@(args["<exp>"]))
    except IndexError:
      quit("Imbalanced input.")
    except ValueError:
      echo getCurrentExceptionMsg()

    if mainStack.len > 0:
      mainStack.peek()
    if mainStack.len > 1:
      echo "Stack remaining: [" & join(mainStack[..(mainStack.high-1)], " ") & "]"

  else:
    while true:
      stdout.write "> "
      let input = readLine stdin
      try:
        mainStack = mainStack.ingestLine(input)
      except IndexError:
        echo "Not enough stack."
      except ValueError:
        echo getCurrentExceptionMsg()

