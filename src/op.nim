## Module for defining operators and their behavior. Establishes the basic
## types, instantiates the operator objects themselves, and defines their
## behavior under evaluation as well as inspection by the explain command.
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
        n3Types: array[x..z, ObjectType]
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

proc nullaryOperator(
  operation: NullaryOperation,
  minimumStackLength = zero,
  xType, yType, zType = otNum
): Operator =
  result.arity = nullary
  result.nOperation = operation
  result.minimumStackLength = minimumStackLength

  case minimumStackLength
  of zero:
    discard
  of one:
    result.n1Types = [xType]
  of two:
    result.n2Types = [xType, yType]
  of three:
    result.n3Types = [xType, yType, zType]

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

proc `$`*(o: Operator): string {. noSideEffect .}=
  ## Output type and name of operator.
  let operation = case o.arity:
    of unary: $o.uOperation
    of binary: $o.bOperation
    of nullary: $o.nOperation
    of trinary: $o.tOperation
  $o.arity & " op " & operation

proc `$`*(n: float): string {. noSideEffect .}=
  ## Display whole numbers without a decimal.
  if fmod(n, 1.0) == 0:
    $int(n)
  else:
    system.`$` n

proc initStackObject*(val: Num): StackObj {. noSideEffect .}=
  ## Create a new stack number object.
  result.objectType = otNum
  result.value = val
proc initStackObject*(t: string): StackObj {. noSideEffect .}=
  ## Create a new stack symbol object.
  result.objectType = otSymbol
  result.token = t

proc `$`*(o: StackObj): string {. noSideEffect .}=
  ## Display a stack object. Display whole numbers as integers,
  ## unevaluated symbols as tokens.
  if o.objectType == otNum:
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

proc numberOfArguments(op: Operator): ArgumentNumber {. noSideEffect .}=
  case op.arity:
    of trinary: three
    of binary: two
    of unary: one
    of nullary: op.minimumStackLength.ArgumentNumber

proc getArguments*(op: Operator, stack: Stack): Arguments {. noSideEffect .}=
  ## Given an operator and a stack, return the appropriate argument values for
  ## that operator.
  let argumentNumber = min(op.numberOfArguments.int, stack.len)
  result = stack[^argumentNumber..^1]

proc explain(o: Operator, argStrings: seq[string]): string {. noSideEffect .}=
  let msg = case o.arity:
    of unary:
      case o.uOperation:
        of squared: "$1 ^ 2"
        of negative: "-$1"
        of absolute: "|$1|"
        of squareRoot: "square root of $1"
        of factorial: "$1!"
        of floor: "floor of $1"
        of ceiling: "ceiling of $1"
        of round: "round $1"
    of binary: "$1 " & $o.bOperation & " $2"
    of trinary:
      case o.tOperation:
        of toCond: "if $1 then $2 else $3"
    of nullary:
      case o.nOperation:
        of showLast: "peek at stack"
        of exit: "quit"
        of showStack: "show stack"
        of noClear: "clear stack"
        of dup: "duplicate $1"
        of swapLast: "swap $1 and $2"
        of drop: "drop $1"
        of popLast: "print and drop $1"
        of explainAll: "explain stack"
        of noHistory: "show history"
        of explainToken: "explain $1"
        of noDef: "define $2 as $1"
        of noDel: "remove definition of $1"
        of noLocals: "display variables"
  result = msg % argStrings

proc explain*(o: Operator, stack: Stack): string {. noSideEffect .}=
  ## Given an operator, pull out the appropriate number of arguments
  ## and return a string projecting the given operation.
  let
    argStrings = o.getArguments(stack).mapIt($it)
    name = $o & ":"

  var
    explanation: string
    explainStr = o.explain(argStrings)

  if o.arity == nullary:
    # Output a description of the effect of the stack operator.
    explanation = explainStr
  else:
    # Output a projection of the state of the stack after evaluation.
    let
      r = stack[0..stack.high - argStrings.len]
      remainderStr = if r.len > 0: join(r) & " " else: ""
    explanation = "[$1($2)]" % [remainderStr, explainStr]

  explanation = explanation.align(50 - name.len)
  result = name & explanation

proc getTypes*(op: Operator): Types  {. noSideEffect .}=
  ## Get the expected types for an operator.
  case op.arity:
    of trinary: @(op.tTypes)
    of binary: @(op.bTypes)
    of unary: @(op.uTypes)
    of nullary:
      case op.minimumStackLength:
        of zero: @[]
        of one: @(op.n1Types)
        of two: @(op.n2Types)
        of three: @(op.n3Types)

proc getTypes*(args: Arguments): Types {. noSideEffect .}=
  ## Get the types for a set of command arguments.
  args.mapIt(it.objectType)

proc typeCheck*(op: Operator, stack: Stack): bool {. noSideEffect .}=
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

proc eval*(op: Operator, x, y, z: Num): Num {. noSideEffect .}=
  case op.tOperation:
    of toCond:
      if bool(x): y else: z

proc eval*(op: Operator; x, y: Num): Num {. noSideEffect .}=
  ## Evaluation of binary operations.
  case op.bOperation:
    of plus: x + y
    of minus: x - y
    of times: x * y
    of into: x / y
    of power: pow(x, y)
    of boGreater: float(x > y)
    of boLess: float(x < y)
    of boEqualTo: float(x == y)

proc eval*(op: Operator, x: Num): Num {. noSideEffect .}=
  ## Evaluation of unary operations.
  case op.uOperation:
    of squared: x * x
    of negative: -x
    of absolute: abs(x)
    of squareRoot: sqrt(x)
    of floor: floor(x)
    of ceiling: ceil(x)
    of round: round(x)
    of factorial:
      # factorial is more accurate...
      if fmod(x, 1.0) == 0: float(fac(int(x)))
      # but extend with the gamma function if necessary.
      else: tgamma(x+1)
