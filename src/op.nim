import options, strutils, math, sequtils

const
  plusSign = "+"
  minusSign = "-"
  timesSign = "*"
  intoSign = "/"
  powerSign = "^"
  squaredSign = "sqr"
  negativeSign = "neg"
  absoluteSign = "abs"
  squareRootSign = "sqrt"
  factorialSign = "!"
  floorSign = "floor"
  ceilingSign = "ceil"
  roundSign = "round"
  showLastSign = "peek"
  showStackSign = "show"
  clearSign = "clear"
  exitSign = "quit"
  dupSign = "dup"
  dropSign = "drop"
  swapSign = "swap"
  popSign = "pop"
  explainSign = "?"
  explainAllSign = "??"
  historySign = "hist"
  defSign = "="
  delSign = "undef"
  localsSign = "vars"
  greaterSign = ">"
  lessSign = "<"
  equalToSign = "=="
  condSign = "cond"

type
  ObjectType = enum
    otSymbol = "Symbol"
    otNum = "Number"
  Types = seq[ObjectType]
  Arity* = enum
    unary, binary, trinary, nullary = "stack"
  ArgumentNumber* = enum
    zero, one, two, three
  ArgumentSlot* = enum
    x, y, z
  UnaryOperation* = enum
    squared = squaredSign
    negative = negativeSign
    absolute = absoluteSign
    squareRoot = squareRootSign
    factorial = factorialSign
    floor = floorSign
    ceiling = ceilingSign
    round = roundSign
  BinaryOperation* = enum
    plus = plusSign
    minus = minusSign
    times = timesSign
    into = intoSign
    power = powerSign
    boGreater = greaterSign
    boLess = lessSign
    boEqualTo = equalToSign
  TrinaryOperation* = enum
    toCond = condSign
  NullaryOperation* = enum
    showLast = showLastSign
    showStack = showStackSign
    noClear = clearSign
    exit = exitSign
    dup = dupSign
    drop = dropSign
    swapLast = swapSign
    popLast = popSign
    explainAll = explainAllSign
    noHistory = historySign
    explainToken = explainSign
    noDef = defSign
    noDel = delSign
    noLocals = localsSign
  Operator* = object
    case arity*: Arity
    of unary:
      uOperation*: UnaryOperation
      uTypes: array[x..x, ObjectType]
    of binary:
      bOperation*: BinaryOperation
      bTypes: array[x..y, ObjectType]
    of trinary:
      tOperation*: TrinaryOperation
      tTypes: array[x..z, ObjectType]
    of nullary:
      nOperation*: NullaryOperation
      case minimumStackLength*: ArgumentNumber
      of one:
        n1Types: array[x..x, ObjectType]
      of two:
        n2Types: array[x..y, ObjectType]
      of three:
        n3Types: array[x..y, ObjectType]
      of zero:
        discard
  Num* = float
  StackObj* = object
    case objectType: ObjectType
    of otNum:
      value*: Num
    of otSymbol:
      token*: string
  Stack* = seq[StackObj]
  Arguments = seq[StackObj]

var OPERATORS = newSeq[Operator]()

proc unaryOperator(operation: UnaryOperation, types = [otNum]): Operator =
  result.arity = unary
  result.uOperation = operation
  result.uTypes = types

  OPERATORS.add(result)

proc binaryOperator(operation: BinaryOperation, types = [otNum, otNum]): Operator =
  result.arity = binary
  result.bOperation = operation
  result.bTypes = types

  OPERATORS.add(result)

proc trinaryOperator(operation: TrinaryOperation, types = [otNum, otNum, otNum]): Operator =
  result.arity = trinary
  result.tOperation = operation
  result.tTypes = types

  OPERATORS.add(result)

proc nullaryOperator(operation: NullaryOperation, minimumStackLength = zero, xType, yType = otNum): Operator =
  result.arity = nullary
  result.nOperation = operation
  result.minimumStackLength = minimumStackLength
  case minimumStackLength
  of zero, three:
    discard
  of one:
    result.n1Types = [xType]
  of two:
    result.n2Types = [xType, yType]

  OPERATORS.add(result)

let
  PLUS = binaryOperator(plus)
  MINUS = binaryOperator(minus)
  TIMES = binaryOperator(times)
  INTO = binaryOperator(into)
  POWER = binaryOperator(power)
  GREATERTHAN = binaryOperator(boGreater)
  LESSTHAN = binaryOperator(boLess)
  EQUALTO = binaryOperator(boEqualTo)
  SQUARED = unaryOperator(squared)
  ABSOLUTE = unaryOperator(absolute)
  NEGATIVE = unaryOperator(negative)
  SQUAREROOT = unaryOperator(squareRoot)
  FACTORIAL = unaryOperator(factorial)
  FLOOR = unaryOperator(floor)
  CEILING = unaryOperator(ceiling)
  COND = trinaryOperator(toCond)
  ROUND = unaryOperator(round)
  PEEK = nullaryOperator(showLast, minimumStackLength = one)
  QUIT = nullaryOperator(exit)
  SHOW = nullaryOperator(showStack)
  CLEAR = nullaryOperator(noClear)
  DUP = nullaryOperator(dup, minimumStackLength = one)
  SWAP = nullaryOperator(swapLast, minimumStackLength = two)
  DROP = nullaryOperator(drop, minimumStackLength = one)
  POP = nullaryOperator(popLast, minimumStackLength = one)
  EXPLAIN = nullaryOperator(explainToken, minimumStackLength = one, xType = otSymbol)
  EXPLAIN_ALL = nullaryOperator(explainAll)
  HISTORY = nullaryOperator(noHistory)
  DEF = nullaryOperator(noDef, minimumStackLength = two, yType = otSymbol)
  DEL = nullaryOperator(noDel, minimumStackLength = one, xType = otSymbol)
  LOCALS = nullaryOperator(noLocals)

proc `$`*(o: Operator): string =
  ## Output type and name of operator.
  let operation = case o.arity:
    of unary: $o.uOperation
    of binary: $o.bOperation
    of nullary: $o.nOperation
    of trinary: $o.tOperation
  $o.arity & " op " & operation

proc `$`*(n: float): string =
  if fmod(n, 1.0) == 0:
    $int(n)
  else:
    system.`$` n

proc initStackObject*(val: Num): StackObj =
  result.objectType = otNum
  result.value = val
proc initStackObject*(t: string): StackObj =
  result.objectType = otSymbol
  result.token = t

proc isEval*(o: StackObj): bool =
  o.objectType == otNum

proc `$`*(o: StackObj): string =
  ## Display a stack object. Display whole numbers as integers,
  ## unevaluated symbols as tokens.
  if o.isEval:
    $o.value
  else:
    o.token

proc join*[T](stack: T): string =
  ## Concatenate the stack with spaces.
  strutils.join(stack, " ")

proc `$`*(types: Types): string = "(" & join(types) & ")"
proc `$`*(stack: Stack): string = "[" & join(stack) & "]"

proc getOperator*(t: string): Option[Operator] =
  ## Return an operator if it matches to a given token.
  case t
  of plusSign: some PLUS
  of minusSign: some MINUS
  of "x", timesSign: some TIMES
  of intoSign: some INTO
  of powerSign, "**", "pow": some POWER
  of greaterSign, "gt": some GREATERTHAN
  of lessSign, "lt": some LESSTHAN
  of equalToSign, "eq": some EQUALTO
  of condSign: some COND
  of squaredSign: some SQUARED
  of absoluteSign: some ABSOLUTE
  of negativeSign: some NEGATIVE
  of squareRootSign: some SQUAREROOT
  of factorialSign, "fac": some FACTORIAL
  of floorSign, "fl": some FLOOR
  of ceilingSign: some CEILING
  of roundSign: some ROUND
  of "p", showLastSign: some PEEK
  of "q", exitSign: some QUIT
  of "s", showStackSign, "stack": some SHOW
  of "c", clearSign: some CLEAR
  of dupSign: some DUP
  of swapSign: some SWAP
  of dropSign: some DROP
  of popSign, ".": some POP
  of explainSign, "explain": some EXPLAIN
  of explainAllSign, "explain-all": some EXPLAIN_ALL
  of historySign, "history": some HISTORY
  of defSign, "def": some DEF
  of delSign: some DEL
  of localsSign: some LOCALS
  else: none(Operator)

proc numberOfArguments(op: Operator): ArgumentNumber =
  case op.arity:
    of trinary: three
    of binary: two
    of unary: one
    of nullary: op.minimumStackLength.ArgumentNumber

proc explain(o: Operator, x: string): string =
  case o.uOperation:
    of squared: "$1 ^ 2" % x
    of negative: "-$1" % x
    of absolute: "|$1|" % x
    of squareRoot: "square root of $1" % x
    of factorial: x & factorialSign
    of floor: "floor of $1" % x
    of ceiling: "ceiling of $1" % x
    of round: "round $1" % x

proc explain(o: Operator, x, y: string): string =
  "$1 $2 $3" % [x, $o.bOperation, y]

proc explain(o: Operator, x, y, z: string): string =
  case o.tOperation:
    of toCond: "if $1 then $2 else $3" % [x, y, z]

proc stackOperatorExplain(o: Operator, x = "NA", y = "NA"): string =
  case o.nOperation:
    of showLast: "peek at stack"
    of exit: "quit"
    of showStack: "show stack"
    of noClear: "clear stack"
    of dup: "duplicate $1" % x
    of swapLast: "swap $1 and $2" % [x, y]
    of drop: "drop $1" % x
    of popLast: "print and drop $1" % x
    of explainAll: "explain stack"
    of noHistory: "show history"
    of explainToken: "explain $1" % x
    of noDef: "define $1 as $2" % [x, y]
    of noDel: "remove definition of $1" % x
    of noLocals: "display variables"

proc remainderStr(stack: Stack): string =
  if stack.len > 0: join(stack) & " "
  else: ""

proc explain*(o: Operator, stack: Stack): string =
  ## Given an operator, pull out the appropriate number of arguments
  ## and return a string projecting the given operation.
  var
    x, y, z: string
    remainder: Stack
    explainStr, remainderStr: string

  case o.numberOfArguments:
    of three:
      z = $stack[^1]
      y = $stack[^2]
      x = $stack[^3]
    of two:
      y = $stack[^1]
      x = $stack[^2]
    of one:
      x = $stack[^1]
    else:
      discard

  case o.arity
  of unary:
    remainder = stack[0..stack.high - 1]
    remainderStr = remainder.remainderStr
    explainStr = "(" & o.explain(x) & ")"
  of binary:
    remainder = stack[0..stack.high - 2]
    remainderStr = remainder.remainderStr
    explainStr = "(" & o.explain(x, y) & ")"
  of trinary:
    remainder = stack[0..stack.high - 3]
    remainderStr = remainder.remainderStr
    explainStr = "(" & o.explain(x, y, z) & ")"
  of nullary:
    remainder = stack
    remainderStr = ""

    case o.minimumStackLength
    of zero, three:
      explainStr = o.stackOperatorExplain()
    of one:
      explainStr = o.stackOperatorExplain(x = x)
    of two:
      explainStr = o.stackOperatorExplain(x = x, y = y)
  let
    name = $o & ":"
    explanation = (
      "[" & remainderStr & explainStr & "]"
    ).align(50 - name.len)

  name & explanation

proc getArguments*(op: Operator, stack: Stack): Arguments =
  ## Given an operator and a stack, return the appropriate argument values for
  ## that operator.
  let argumentNumber = min(op.numberOfArguments.int, stack.len)
  result = stack[^argumentNumber..^1]

proc getTypes*(op: Operator): Types =
  ## Get the expected types for an operator.
  case op.arity:
    of trinary: @(op.tTypes)
    of binary: @(op.bTypes)
    of unary: @(op.uTypes)
    of nullary:
      case op.minimumStackLength:
        of zero, three: @[]
        of one: @(op.n1Types)
        of two: @(op.n2Types)

proc getTypes*(args: Arguments): Types =
  ## Get the types for a set of command arguments.
  args.mapIt(it.objectType)

proc typeCheck*(op: Operator, stack: Stack): bool =
  ## Perform runtime type checking, checking whether the number and type of
  ## arguments in the stack matches the expected argument number and type of
  ## the operator.
  let
    expectedArgumentNumber = op.numberOfArguments
    arguments = op.getArguments(stack)

  if arguments.len < expectedArgumentNumber.int:
    return false

  let
    requiredTypes = op.getTypes()
    argTypes = arguments.getTypes()
  result = requiredTypes == argTypes

proc explain*(stack: Stack): string =
  ## Generate explanatory text for all operators eligible for the
  ## current stack.
  OPERATORS.filterIt(it.typeCheck(stack)).mapIt(it.explain(stack)).join("\n")

proc eval*(op: Operator, x, y, z: Num): Num =
  case op.tOperation:
    of toCond:
      if bool(x): y else: z

proc eval*(op: Operator; x, y: Num): Num =
  ## Evaluation of binary operations.
  case op.bOperation:
    of plus:
      result = x + y
    of minus:
      result = x - y
    of times:
      result = x * y
    of into:
      result = x / y
    of power:
      result = pow(x, y)
    of boGreater:
      result = float(x > y)
    of boLess:
      result = float(x < y)
    of boEqualTo:
      result = float(x == y)

proc eval*(op: Operator, x: Num): Num =
  ## Evaluation of unary operations.
  case op.uOperation:
    of squared:
      result = x * x
    of negative:
      result =  -x
    of absolute:
      result = abs(x)
    of squareRoot:
      result = sqrt(x)
    of factorial:
      if fmod(x, 1.0) != 0:
        raise newException(ValueError, "Can only take ! of whole numbers.")
      result = float(fac(int(x)))
    of floor:
      result = floor(x)
    of ceiling:
      result = ceil(x)
    of round:
      result = round(x)
