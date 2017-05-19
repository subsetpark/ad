import strutils, math, options, tables
import obj, op, parse, explain

const HISTORY_MAX_LENGTH = 250

var
  history: Stack = @[]
  locals = initTable[string, Num]()

proc peek(stack: Stack) =
  ## Display the top element of the stack.
  echo(if stack.len > 0: $stack[^1] else: "")

proc show(stack: Stack) =
  ## Display the whole stack.
  echo $stack

proc displaySummary*(stack: Stack) =
  ## Display stack state on exit.
  if stack.len > 0:
    stack.peek()
  if stack.len > 1:
    echo "Stack remaining:"
    stack[0..(^2)].show()

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
    echo "$1: $2" % [sign, obj.`$`(value)]

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
    echo stack.explain(x)
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

proc operate(stack: var Stack, op: Operator): Num {. noSideEffect .}=
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
    raise newException(ValueError, "Stack operators have no return value.")

proc raiseTypeException(operator: Operator, stack: Stack) =
  ## Get type information for operator and arguments and raise.
  var
    msg: string
    arguments = operator.getArguments(stack)

  msg = "type failure.\n. operator: $1\n. expected types: $2\n. received types: $3" % [
      $operator, $operator.getTypes, $getTypes(arguments)
    ]
  raise newException(ValueError, msg)

proc evaluateOperator(stack: var Stack, operator: Operator): Option[StackObj] =
  ## Evaluate an operator against a stack, either mutating the stack or
  ## returning a new stack object.

  # Perform runtime type checking, compare expected types of operator against
  # argument types.
  if not operator.typeCheck(stack):
    raiseTypeException(operator, stack)

  case operator.arity
  of nullary:
    result = none(StackObj)
    operator.mutate(stack)

  else:
    result = some(initStackObject(stack.operate(operator)))
    history.add(result.get())
    if history.len > HISTORY_MAX_LENGTH:
      history.delete(0)

proc ingest(stack: var Stack, t: string) =
  ## Given a token, convert the token into a stack object or operator and then
  ## process it as appropriate.
  let operatorOrObj = locals.parseToken(t)
  if operatorOrObj.isObj:
    stack.add(operatorOrObj.obj)
  else:
    let newObj = stack.evaluateOperator(operatorOrObj.op)
    if newObj.isSome:
      stack.add(newObj.get())

proc ingestLine*(stack: var Stack, tokens: seq[string]) =
  ## Process an entire line of tokens.
  for t in tokens:
    stack.ingest(t)
