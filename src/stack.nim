import strutils, math, options, sequtils
import op

const
  HISTORY_MAX_LENGTH = 250
  QUOTE* = ['\'', '`']

var history: Stack = @[]

proc peek(stack: Stack) =
  ## Display the top element of the stack.
  if len(stack) > 0:
    let r = stack[stack.high]
    echo $r
  else:
    echo ""

proc show(stack: Stack) =
  ## Display the whole stack.
  echo $stack

proc handleExit*(stack: Stack) =
  ## Display stack state on exit.
  if stack.len > 0:
    stack.peek()
  if stack.len > 1:
    echo "Stack remaining:"
    stack[..(stack.high-1)].show()

proc showTail(stack: Stack, tailLength = 8) =
  ## Display the last `tailLength` stack elements, in reverse order.
  var i = stack.high
  while i >= stack.low and (stack.high - i) < tailLength:
    echo $(i + 1) & ": " & $stack[i]
    i -= 1

proc showHistory*() =
  ## Display expression history.
  history.showTail()

proc dropLast(stack: var Stack) =
  stack.setLen(stack.len - 1)

proc mutate(op: Operator, stack: var Stack) =
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
  of explainAll:
    echo stack.explain()
  of noHistory:
    showHistory()


proc operate(stack: var Stack, op: Operator): Option[StackObj] =
  case op.arity
  of unary:
    if stack.len < 1:
      raise newException(IndexError, "Not enough stack.")
    let x = stack.pop()

    try:
      result = eval(op, x, stack)
    except FieldError:
      raise newException(ValueError, "Could not evaluate $1 with unevaluated word: $2" % [$op, $x])

  of binary:
    ## Processing a binary operator: pop the last two
    ## items on the stack and push the result.
    if stack.len < 2:
      raise newException(IndexError, "Not enough stack.")
    let
      y = stack.pop()
      x = stack.pop()

    try:
      result = some(StackObj(
        isEval: true,
        value: eval(op, x.value, y.value)
      ))
    except FieldError:
      raise newException(ValueError, "Could not evaluate $1 with unevaluated word(s): $2" % [$op, @[y, x].filterIt(not it.isEval).join(", ")])

  else:
    raise newException(ValueError, "Nullary Operators have no return value.")


proc EvaluateToken(stack: var Stack, t: string): Option[StackObj] =
  ## Evaluate a token in the context of a stack and return a new
  ## StackObj, if appropriate.
  var floatValue: Num = NaN
  if t != ".":
    try:
      floatValue = parseFloat(t)
    except ValueError:
      discard

  if floatValue.classify != fcNan:
    result = some(StackObj(
      isEval: true,
      value: floatValue)
    )

  else:
    let maybeOperator = getOperator(t)

    if maybeOperator.isSome:
      let operator = maybeOperator.get()

      if operator.arity == nullary:
        operator.mutate(stack)
        result = none(StackObj)

      else:
        result = stack.operate(operator)
        if result.isSome:
          history.add(result.get())
          if history.len > HISTORY_MAX_LENGTH:
            history.delete(0)

    else:
      case t[0]
      of QUOTE:
        result = some(StackObj(token: t[1..t.high]))
      else:
        raise newException(ValueError, "Unrecognized token: $1" % t)


proc ingest(stack: var Stack, t: string) =
  ## Given a token, convert the token into a float or operator and
  ## then process it as appropriate.
  let newObj = EvaluateToken(stack, t)
  if newObj.isSome:
    stack.add(newObj.get())

proc ingestLine*(stack: var Stack, tokens: seq[string]) =
  ## Process an entire line of tokens.
  for t in tokens:
    stack.ingest(t)
