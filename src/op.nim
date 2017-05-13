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
  Arity* = enum
    unary, binary, trinary, nullary = "stack"
  Operator* = object
    case arity*: Arity
    of unary: uOperation*: UnaryOperation
    of binary: bOperation*: BinaryOperation
    of trinary: tOperation*: TrinaryOperation
    of nullary:
      nOperation*: NullaryOperation
      minimumStackLength*: int
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
  Num* = float
  StackObj* = object
    case isEval*: bool
    of true:
      value*: Num
    of false:
      token*: string
  Stack* = seq[StackObj]

var UNARY_OPERATORS, BINARY_OPERATORS, TRINARY_OPERATORS, NULLARY_OPERATORS = newSeq[Operator]()

proc unaryOperator(operation: UnaryOperation): Operator =
  result.arity = unary
  result.uOperation = operation

  UNARY_OPERATORS.add(result)

proc binaryOperator(operation: BinaryOperation): Operator =
  result.arity = binary
  result.bOperation = operation

  BINARY_OPERATORS.add(result)

proc trinaryOperator(operation: TrinaryOperation): Operator =
  result.arity = trinary
  result.tOperation = operation

  TRINARY_OPERATORS.add(result)

proc nullaryOperator(operation: NullaryOperation, minimumStackLength = 0): Operator =
  result.arity = nullary
  result.nOperation = operation
  result.minimumStackLength = minimumStackLength

  NULLARY_OPERATORS.add(result)

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
  PEEK = nullaryOperator(showLast, minimumStackLength = 1)
  QUIT = nullaryOperator(exit)
  SHOW = nullaryOperator(showStack)
  CLEAR = nullaryOperator(noClear)
  DUP = nullaryOperator(dup, minimumStackLength = 1)
  SWAP = nullaryOperator(swapLast, minimumStackLength = 2)
  DROP = nullaryOperator(drop, minimumStackLength = 1)
  POP = nullaryOperator(popLast, minimumStackLength = 1)
  EXPLAIN = nullaryOperator(explainToken, minimumStackLength = 1)
  EXPLAIN_ALL = nullaryOperator(explainAll)
  HISTORY = nullaryOperator(noHistory)
  DEF = nullaryOperator(noDef, minimumStackLength = 2)
  DEL = nullaryOperator(noDel, minimumStackLength = 1)
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

proc `$`*(o: StackObj): string =
  ## Display a stack object. Display whole numbers as integers,
  ## unevaluated symbols as tokens.
  if o.isEval:
    $o.value
  else:
    o.token

proc join*(stack: Stack): string =
  ## Concatenate the stack with spaces.
  strutils.join(stack, " ")

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

proc stackOperatorExplain(o: Operator, y = "NA", x = "NA"): string =
  case o.nOperation:
    of showLast: "peek at stack"
    of exit: "quit"
    of showStack: "show stack"
    of noClear: "clear stack"
    of dup: "duplicate $1" % y
    of swapLast: "swap $1 and $2" % [x, y]
    of drop: "drop $1" % y
    of popLast: "print and drop $1" % y
    of explainAll: "explain stack"
    of noHistory: "show history"
    of explainToken: "explain $1" % y
    of noDef: "define $1 as $2" % [y, x]
    of noDel: "remove definition of $1" % y
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

  case o.arity
  of unary:
    y = $stack[^1]
    remainder = stack[0..stack.high - 1]
    remainderStr = remainder.remainderStr
    explainStr = "(" & o.explain(y) & ")"
  of binary:
    y = $stack[^1]
    x = $stack[^2]
    remainder = stack[0..stack.high - 2]
    remainderStr = remainder.remainderStr
    explainStr = "(" & o.explain(x, y) & ")"
  of trinary:
    z = $stack[^1]
    y = $stack[^2]
    x = $stack[^3]
    remainder = stack[0..stack.high - 3]
    remainderStr = remainder.remainderStr
    explainStr = "(" & o.explain(x, y, z) & ")"
  of nullary:
    remainder = stack
    remainderStr = ""

    case o.minimumStackLength
    of 0:
      explainStr = o.stackOperatorExplain()
    of 1:
      y = $stack[^1]
      explainStr = o.stackOperatorExplain(y = y)
    else:
      y = $stack[^1]
      x = $stack[^2]
      explainStr = o.stackOperatorExplain(y = y, x = x)
  let
    name = $o & ":"
    explanation = (
      "[" & remainderStr & explainStr & "]"
    ).align(50 - name.len)

  name & explanation

proc getOperatorsForStackLength(length: int): seq[Operator] =
  result = NULLARY_OPERATORS.filterIt(it.minimumStackLength <= length)
  if length >= 1:
    result &= UNARY_OPERATORS
  if length >= 2:
    result &= BINARY_OPERATORS
  if length >= 3:
    result &= TRINARY_OPERATORS

proc explain*(stack: Stack): string =
  ## Generate explanatory text for all operators eligible for the
  ## current stack.
  let eligibleOperators = getOperatorsForStackLength(stack.len)
  eligibleOperators.mapIt(it.explain(stack)).join("\n")

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
