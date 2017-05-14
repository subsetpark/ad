import strutils, math, options, sequtils, tables
import op

const
  HISTORY_MAX_LENGTH = 250
  QUOTE* = ['\'', '`']

var
  history: Stack = @[]
  locals = initTable[string, Num]()

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

proc explain(obj: StackObj, stack: Stack) =
  let opToExplain = getOperator(obj.token)
  if opToExplain.isSome:
    echo opToExplain.get.explain(stack)
  else:
    echo "Don't know " & $obj

proc def(name, value: StackObj) =
  let checkOperator = getOperator(name.token)
  if checkOperator.isSome:
    raise newException(ValueError, "$1 is already defined." % $name)
  locals[name.token] = value.value

proc del(name: StackObj) =
  if name.token notin locals:
    raise newException(ValueError, "$1 not currently a defined variable" % name.token)
  else:
    locals.del(name.token)

proc showLocals() =
  for sign, value in locals:
    echo "$1: $2" % [sign, op.`$`(value)]

proc mutate(op: Operator, stack: var Stack) =
  ## Evaluation of stack operations.
  case op.nOperation
  of showLast:
    stack.peek()
  of showStack:
    stack.show()
  of noClear:
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
  of explainToken:
    let x = stack.pop()
    explain(x, stack)
  of noDef:
    let
      name = stack.pop()
      value = stack.pop()
    def(name, value)
  of noDel:
    let name = stack.pop()
    del(name)
  of noLocals:
    showLocals()

proc operate(stack: var Stack, op: Operator): Num =
  case op.arity
  of unary:
    let x = stack.pop()
    result = eval(op, x.value)

  of binary:
    ## Processing a binary operator: pop the last two
    ## items on the stack and push the result.
    let
      y = stack.pop()
      x = stack.pop()

    result = eval(op, x.value, y.value)

  of trinary:
    let
      z = stack.pop()
      y = stack.pop()
      x = stack.pop()

    result = eval(op, x.value, y.value, z.value)

  of nullary:
    raise newException(ValueError, "Nullary Operators have no return value.")

proc parseFloat(t: string): Option[Num] =
  const specialTokens = ["."]
  case t
  of "e": some E
  of "pi": some PI
  of "tau": some TAU
  of specialTokens: none(Num)
  else:
    try:
      some strutils.parseFloat(t)
    except ValueError:
      none(Num)

proc raiseTypeException(operator: Operator, stack: Stack) =
  ## Get type information for operator and arguments and raise.
  var
    msg: string
    arguments = operator.getArguments(stack)

  msg = "type failure: [$#] requires types $#, but received types $#" % [
      $operator, $operator.getTypes, $getTypes(arguments)
    ]
  raise newException(ValueError, msg)

proc EvaluateToken(stack: var Stack, t: string): Option[StackObj] =
  ## Evaluate a token in the context of a stack and return a new
  ## StackObj, if appropriate.
  let floatValue = parseFloat(t)

  if floatValue.isSome:
    result = some(initStackObject(floatValue.get()))

  elif t in locals:
    result = some(initStackObject(locals[t]))

  else:
    let maybeOperator = getOperator(t)

    if maybeOperator.isSome:
      let operator = maybeOperator.get()
      # Perform runtime type checking, compare expected types of operator
      # against argument types
      if not operator.typeCheck(stack):
        raiseTypeException(operator, stack)

      if operator.arity == nullary:
        operator.mutate(stack)
        result = none(StackObj)

      else:
        result = some(initStackObject(stack.operate(operator)))
        history.add(result.get())
        if history.len > HISTORY_MAX_LENGTH:
          history.delete(0)

    else:
      case t[0]
      of QUOTE:
        result = some(initStackObject(t[1..t.high]))
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
