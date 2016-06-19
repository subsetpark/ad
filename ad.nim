let doc = """
Simple Reverse Polish Calculator.

Usage:
  ad <exp>...
  ad
"""
import docopt, strutils, math, future, sequtils

type 
  BinaryOperator = enum
    plus
    minus
    times
    into
    power
    identity
  UnaryOperator = enum
    squared
    positive
  StackOperator = enum
    noop
    showLast
    exit
    showStack
    clear
  Stack = seq[float]

const binaryTokens = ["+", "-", "*", "/", "^", "**", "pow"]
const unaryTokens = ["sqr"]
const stackTokens = ["p", "q", "s", "c"]

proc `$`(n: float): string =
  ## Overridden toString operator. Numbers are stored as floats, but will be
  ## displayed as integers if possible.
  if fmod(n, 1.0) == 0:
    $int(n)
  else:
    system.`$` n

proc peek(stack: Stack) = 
  ## Display the top element of the stack.
  try:
    let r = stack[stack.high]
    echo $r
  except IndexError:
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
proc eval(stack: Stack, op: StackOperator) =
  ## Evaluation of stack operations.
  case op:
    of showLast:
      stack.peek()
    of showStack:
      stack.show()
    of exit:
      stack.peek()
      quit()
    of clear:
      result 
    else:
      discard

proc operate(stack: Stack, op: BinaryOperator): Stack =
  ## Processing a binary operator: pop the last two items on the stack and push
  ## the result.
  result = stack
  let 
    y = result.pop()
    x = result.pop()
  result.add(eval(op, x, y))

proc operate(stack: Stack, op: UnaryOperator): Stack =
  ## Processing a unary operator: pop the last item on the stack and push the
  ## result.
  result = stack
  let x = result.pop()
  result.add(eval(op, x))

proc operate(stack: Stack, op: StackOperator): Stack =
  ## Processing stack operators: evaluate using the whole stack.
  eval(stack, op)
  result = stack

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
      of "**": power
      of "^": power
      of "pow": power
      else: identity
    result = result.operate(o)
  elif t in unaryTokens:
    let o = case t
      of "sqr": squared
      else: positive
    result = result.operate(o)
  elif t in stackTokens:
    let o = case t
      of "p": showLast
      of "q": exit
      of "s": showStack
      else: noop
    result = result.operate(o)
  else: 
    result = result

proc ingestLine(stack: var Stack, tokens: seq[string]) = 
  ## Process an entire line of tokens.
  for t in tokens:
    stack = stack.ingest(t)

proc ingestLine(stack: var Stack, input: string) =
  ## Tokenize a line of input and then process it.
  let tokens = input.split()
  stack.ingestLine(tokens)

let args = docopt(doc, version="AD 1")

var stack: Stack = @[]

if args["<exp>"]:
  try:
    stack.ingestLine(@(args["<exp>"]))
  except IndexError:
    quit("Imbalanced input.")
else:
  while true:
    stdout.write "> "
    let input = readLine stdin
    try:
      stack.ingestLine(input)
    except IndexError:
      echo "Not enough stack."

if len(stack) > 0:
  stack.peek()
if len(stack) > 1:
  echo "Elements remaining: " & $stack[..(stack.high-1)]
