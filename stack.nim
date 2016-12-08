import strutils, op, tables, math

type
  Stack* = seq[float]

proc `$`(n: float): string =
  ## Overridden toString operator. Numbers are stored as floats, but will be
  ## displayed as integers if possible.
  if fmod(n, 1.0) == 0:
    $int(n)
  else:
    system.`$` n

proc isFloat*(s: string): bool {.noSideEffect, procvar.}=
  ## Checks whether or not `s` is a numeric value.
  ##
  ## This checks 0-9 ASCII characters only.
  ## Returns true if all characters in `s` are
  ## numeric and there is at least one character
  ## in `s`.
  if s.len == 0:
    return false

  result = true

  var seenDecimal = false
  for c in s:
    if c == '.':
      if seenDecimal:
        return false
      seenDecimal = true
    elif not c.isDigit():
      return false

proc peek*(stack: Stack) = 
  ## Display the top element of the stack.
  if len(stack) > 0:
    let r = stack[stack.high]
    echo $r
  else:
    echo ""

proc show(stack: Stack) =
  ## Display the whole stack.
  echo "[" & join(stack, " ") & "]"

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
    else:
      result = stack

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
    of negative:
      -x
    of absolute:
      abs(x)
    of squareRoot:
      sqrt(x)
    of factorial:
      if fmod(x, 1.0) != 0:
        raise newException(ValueError, "Can only take ! of whole numbers.")
      float(fac(int(x)))
    of floor:
      floor(x)
    of ceiling:
      ceil(x)
    of round:
      round(x)
    else:
      x

proc operate(stack: Stack, op: BinaryOperator): Stack =
  ## Processing a binary operator: pop the last two items on the stack and push
  ## the result.
  if stack.len < 2:
    raise newException(IndexError, "Not enough stack.")
  result = stack
  let 
    y = result.pop()
    x = result.pop()
  result.add(eval(op, x, y))

proc operate(stack: Stack, op: UnaryOperator): Stack =
  ## Processing a unary operator: pop the last item on the stack and push the
  ## result.
  if stack.len < 1:
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
  if t.isFloat:
    result.add(parseFloat t)
  elif t in binaryTokens:
    let o = binaryTokens[t]
    result = result.operate(o)
  elif t in unaryTokens:
    let o = unaryTokens[t]
    result = result.operate(o)
  elif t in stackTokens:
    let o = stackTokens[t]
    result = result.operate(o)
  else:
    raise newException(ValueError, "Unknown token: " & t)

proc ingestLine*(stack: Stack, tokens: seq[string]): Stack = 
  ## Process an entire line of tokens.
  result = stack
  for t in tokens:
    result = result.ingest(t)

proc ingestLine*(stack: Stack, input: string): Stack =
  ## Tokenize a line of input and then process it.
  let tokens = input.split()
  result = stack.ingestLine(tokens)

