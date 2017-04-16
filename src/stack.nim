import strutils, math, options
import op

type
  Stack* = seq[float]

proc `$`(n: Num): string =
  ## Overridden toString operator. Due to an existing issue we need to
  ## repeat this overloading from op.nim.
  if fmod(n, 1.0) == 0:
    $int(n)
  else:
    system.`$` n

proc join*(stack: Stack): string =
  strutils.join(stack, " ")

proc `$`(stack: Stack): string =
  "[" & join(stack) & "]"

proc peek*(stack: Stack) =
  ## Display the top element of the stack.
  if len(stack) > 0:
    let r = stack[stack.high]
    echo $r
  else:
    echo ""

proc show*(stack: Stack) =
  ## Display the whole stack.
  echo $stack

proc eval(stack: var Stack, op: StackOperator) =
  ## Evaluation of stack operations.
  case op:
    of soShowLast:
      stack.peek()
    of soShowStack:
      stack.show()
    of soClear:
      stack.setLen(0)
    of soExit:
      stack.peek()
      quit()
    of soDup:
      stack.add(stack[stack.high])
    of soSwap:
      let
        x = stack.pop()
        y = stack.pop()
      stack.add(x)
      stack.add(y)

proc eval(op: BinaryOperator; x, y: Num): Num =
  ## Evaluation of binary operations.
  case op:
    of boPlus:
      result = x + y
    of boMinus:
      result = x - y
    of boTimes:
      result = x * y
    of boInto:
      result = x / y
    of boPower:
      result = pow(x, y)

proc eval(op: UnaryOperator, x: Num): Num =
  ## Evaluation of unary operations.
  case op:
    of uoSquared:
      result = pow(x, x)
    of uoNegative:
      result = -x
    of uoAbsolute:
      result = abs(x)
    of uoSquareRoot:
      result = sqrt(x)
    of uoFactorial:
      if fmod(x, 1.0) != 0:
        raise newException(ValueError, "Can only take ! of whole numbers.")
      result = float(fac(int(x)))
    of uoFloor:
      result = floor(x)
    of uoCeiling:
      result = ceil(x)
    of uoRound:
      result = round(x)

proc operate(stack: var Stack, op: BinaryOperator): Num =
  ## Processing a binary operator: pop the last two items on the stack and push
  ## the result.
  if stack.len < 2:
    raise newException(IndexError, "Not enough stack.")
  let
    y = stack.pop()
    x = stack.pop()
  result = eval(op, x, y)

proc operate(stack: var Stack, op: UnaryOperator): Num =
  ## Processing a unary operator: pop the last item on the stack and push the
  ## result.
  if stack.len < 1:
    raise newException(IndexError, "Not enough stack.")
  let x = stack.pop()
  result = eval(op, x)

proc ingest(stack: var Stack, t: string) =
  ## Given a token, convert the token into a float or operator and then process
  ## it as appropriate.
  try:
    let f = parseFloat t
    stack.add(f)
  except ValueError:
    let binaryOperator = t.getBinaryOperator()
    if binaryOperator.isSome:
      stack.add(stack.operate(binaryOperator.get()))
      return
    let unaryOperator = t.getUnaryOperator()
    if unaryOperator.isSome:
      stack.add(stack.operate(unaryOperator.get()))
      return
    let stackOperator = t.getStackOperator()
    if stackOperator.isSome:
      stack.eval(stackOperator.get())
      return

    raise newException(ValueError, "Unknown token: " & t)

proc ingestLine*(stack: var Stack, tokens: seq[string]) =
  ## Process an entire line of tokens.
  for t in tokens:
    stack.ingest(t)

proc ingestLine*(stack: var Stack, input: string) =
  ## Tokenize a line of input and then process it.
  let
    tokens = input.split()
    oldStack = stack
  try:
    stack.ingestLine(tokens)
  except IndexError, ValueError:
    stack = oldStack
    raise
