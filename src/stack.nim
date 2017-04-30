import strutils, math, options
import op

const HISTORY_MAX_LENGTH = 250

proc `$`(n: Num): string =
  ## Overridden toString operator. Due to an existing issue we need to
  ## repeat this overloading from op.nim.
  if fmod(n, 1.0) == 0:
    $int(n)
  else:
    system.`$` n

proc join*(stack: Stack): string = strutils.join(stack, " ")

proc `$`(stack: Stack): string = "[" & join(stack) & "]"

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

proc showTail(stack: Stack, tailLength = 8) =
  ## Display the last `tailLength` stack elements, in reverse order.
  var i = stack.high
  while i >= stack.low and (stack.high - i) < tailLength:
    echo $(i + 1) & ": " & $stack[i]
    i -= 1

proc dropLast(stack: var Stack) =
  stack.setLen(stack.len - 1)

proc mutate*(op: Operator, stack: var Stack) =
  ## Evaluation of stack operations.
  case op.nOperation
  of showLast:
    stack.peek()
  of showStack:
    stack.show()
  of clear:
    stack.setLen(0)
  of exit:
    stack.peek()
    quit()
  of dup:
    stack.add(stack[stack.high])
  of swapLast:
    let
      x = stack.pop()
      y = stack.pop()
    stack.add(x)
    stack.add(y)
  of drop:
    stack.dropLast()
  of popLast:
    stack.peek()
    stack.dropLast()

proc operate(stack: var Stack, op: Operator): Num =
  case op.arity
  of unary:
    if stack.len < 1:
      raise newException(IndexError, "Not enough stack.")
    let x = stack.pop()
    result = eval(op, x)
  of binary:
    ## Processing a binary operator: pop the last two items on the stack and push
    ## the result.
    if stack.len < 2:
      raise newException(IndexError, "Not enough stack.")
    let
      y = stack.pop()
      x = stack.pop()
    result = eval(op, x, y)
  else:
    raise newException(ValueError, "Nullary Operators have no return value.")

var history: Stack = @[]

proc ingest(stack: var Stack, t: string) =
  ## Given a token, convert the token into a float or operator and
  ## then process it as appropriate.
  block parseFloatBlock:
    # Manual excepting float-alike tokens
    if t == ".":
      break parseFloatBlock

    try:
      let f = parseFloat t
      stack.add(f)
      return
    except ValueError:
      break parseFloatBlock

  let maybeOperator = getOperator(t)

  if maybeOperator.isNone:
    raise newException(ValueError, "Unknown token: " & t)
  else:
    let operator = maybeOperator.get()

    if operator.arity == nullary:
      operator.mutate(stack)

    else:
      let value = stack.operate(operator)
      stack.add(value)
      history.add(value)
      if history.len > HISTORY_MAX_LENGTH:
        history.delete(0)

proc showHistory*() = history.showTail()

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
