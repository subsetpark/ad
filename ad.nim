import docopt, strutils, math, future, sequtils


type 
  BinaryOperator = enum
    plus
    minus
    times
    into
    power
    left
  UnaryOperator = enum
    squared
    positive
  StackOperator = enum
    showLast
    showStack
    clear
    exit
    noop
  Stack = seq[float]

const doc = """
Simple Reverse Polish Calculator.

Usage:
  ad <exp>...
  ad

If passed any arguments, ad will interpret
them as a series of commands. Otherwise it 
will enter interactive mode, where you can 
use it as a shell for running calculations.
"""

const binaryTokens = ["+", "-", "*", "/", "^", "**", "pow"]
const unaryTokens = ["sqr"]
const stackTokens = ["p", "peek", "q", "quit", "s", "show", "stack", "c", "clear"]

proc `$`(n: float): string =
  ## Overridden toString operator. Numbers are stored as floats, but will be
  ## displayed as integers if possible.
  if fmod(n, 1.0) == 0:
    $int(n)
  else:
    system.`$` n

proc peek(stack: Stack) = 
  ## Display the top element of the stack.
  if len(stack) > 0:
    let r = stack[stack.high]
    echo $r
  else:
    echo ""

proc show(stack: Stack) =
  ## Display the whole stack.
  echo join(stack, " ")


proc eval(op: BinaryOperator; x, y: float): float =
  ## Evaluation of binary operations.
  case op:
    of plus:
      x + y
    of minus:
      x - y
    of times:
      x * y
    of into:
      x / y 
    of power:
      pow(x, y)
    else:
      x
proc eval(op: UnaryOperator, x: float): float =
  ## Evaluation of unary operations.
  case op:
    of squared:
      pow(x, x)
    else:
      x
proc eval(stack: Stack, op: StackOperator): Stack =
  ## Evaluation of stack operations.
  case op:
    of showLast:
      stack.peek()
      result = stack
    of showStack:
      stack.show()
      result = stack
    of clear:
      result = newSeq[float]()
    of exit:
      stack.peek()
      quit()
    of noop:
      result = stack

proc operate(stack: Stack, op: BinaryOperator): Stack =
  ## Processing a binary operator: pop the last two items on the stack and push
  ## the result.
  if stack.len() < 2:
    raise newException(IndexError, "Not enough stack.")
  result = stack
  let 
    y = result.pop()
    x = result.pop()
  result.add(eval(op, x, y))

proc operate(stack: Stack, op: UnaryOperator): Stack =
  ## Processing a unary operator: pop the last item on the stack and push the
  ## result.
  if stack.len() < 1:
    raise newException(IndexError, "Not enough stack.")
  result = stack
  let x = result.pop()
  result.add(eval(op, x))

proc operate(stack: Stack, op: StackOperator): Stack =
  ## Processing stack operators: evaluate using the whole stack.
  eval(stack, op)

proc ingest(stack: Stack, t: string): Stack =
  ## Given a token, convert the token into a float or operator and then process
  ## it as appropriate.
  result = stack
  if t.isDigit: 
    result.add(parseFloat t)
  elif t in binaryTokens:
    let o = case t
      of "+": plus
      of "-": minus
      of "*": times
      of "/": into
      of "**", "^", "pow": power
      else: left
    result = result.operate(o)
  elif t in unaryTokens:
    let o = case t
      of "sqr": squared
      else: positive
    result = result.operate(o)
  elif t in stackTokens:
    let o = case t
      of "p", "peek": showLast
      of "q", "quit": exit
      of "s", "show", "stack": showStack
      of "c", "clear": clear
      else: noop
    result = result.operate(o)
  else:
    raise newException(ValueError, "Unknown token: " & t)


proc ingestLine(stack: Stack, tokens: seq[string]): Stack = 
  ## Process an entire line of tokens.
  result = stack
  for t in tokens:
    result = result.ingest(t)

proc ingestLine(stack: Stack, input: string): Stack =
  ## Tokenize a line of input and then process it.
  let tokens = input.split()
  result = stack.ingestLine(tokens)

let args = docopt(doc, version="AD 1")



when defined(testing):
  include tests
else:
  var stack: Stack = @[]
  if args["<exp>"]:
    try:
      stack = stack.ingestLine(@(args["<exp>"]))
    except IndexError:
      quit("Imbalanced input.")
    except ValueError:
      echo getCurrentExceptionMsg()
  else:
    while true:
      stdout.write "> "
      let input = readLine stdin
      try:
        stack = stack.ingestLine(input)
      except IndexError:
        echo "Not enough stack."
      except ValueError:
        echo getCurrentExceptionMsg()

  if len(stack) > 0:
    stack.peek()
  if len(stack) > 1:
    echo "Elements remaining: " & $stack[..(stack.high-1)]
