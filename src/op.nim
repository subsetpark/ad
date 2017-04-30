import options, strutils, math, sequtils
import typetraits

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

type
  Arity* = enum
    unary, binary, nullary = "stack"
  Operator* = object
    case arity*: Arity
    of unary: uOperation*: UnaryOperation
    of binary: bOperation*: BinaryOperation
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
  NullaryOperation* = enum
    showLast = showLastSign
    showStack = showStackSign
    clear = clearSign
    exit = exitSign
    dup = dupSign
    drop = dropSign
    swapLast = swapSign
    popLast = popSign
  Num* = float
  Stack* = seq[float]

proc `$`(n: Num): string =
  ## Overridden toString operator. Numbers are stored as floats, but will be
  ## displayed as integers if possible.
  if fmod(n, 1.0) == 0:
    $int(n)
  else:
    system.`$` n

var UNARY_OPERATORS, BINARY_OPERATORS, NULLARY_OPERATORS = newSeq[Operator]()

proc unaryOperator(operation: UnaryOperation): Operator =
  result.arity = unary
  result.uOperation = operation

  UNARY_OPERATORS.add(result)

proc binaryOperator(operation: BinaryOperation): Operator =
  result.arity = binary
  result.bOperation = operation

  BINARY_OPERATORS.add(result)

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
  SQUARED = unaryOperator(squared)
  ABSOLUTE = unaryOperator(absolute)
  NEGATIVE = unaryOperator(negative)
  SQUAREROOT = unaryOperator(squareRoot)
  FACTORIAL = unaryOperator(factorial)
  FLOOR = unaryOperator(floor)
  CEILING = unaryOperator(ceiling)
  ROUND = unaryOperator(round)
  PEEK = nullaryOperator(showLast, minimumStackLength = 1)
  QUIT = nullaryOperator(exit)
  SHOW = nullaryOperator(showStack)
  CLEAR = nullaryOperator(clear)
  DUP = nullaryOperator(dup, minimumStackLength = 1)
  SWAP = nullaryOperator(swapLast, minimumStackLength = 2)
  DROP = nullaryOperator(drop, minimumStackLength = 1)
  POP = nullaryOperator(popLast, minimumStackLength = 1)

proc getOperator*(t: string): Option[Operator] =
  case t
  of plusSign: some PLUS
  of minusSign: some MINUS
  of "x", timesSign: some TIMES
  of intoSign: some INTO
  of powerSign, "**", "pow": some POWER
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
  of "d", dupSign: some DUP
  of "sw", swapSign: some SWAP
  of "dr", dropSign: some DROP
  of popSign, ".": some POP
  else: none(Operator)

proc explain*(o: Operator, x: Num): string =
  # if o.arity != unary:
  #   raise newException(TypeError, "Wrong number of arguments passed to operator.")
  let x = $x
  case o.uOperation:
    of squared: "$1 ^ 2" % x
    of negative: "-$1" % x
    of absolute: "|$1|" % x
    of squareRoot: "square root of $1" % x
    of factorial: x & factorialSign
    of floor: "floor of $1" % x
    of ceiling: "ceiling of $1" % x
    of round: "round $1" % x

proc explain*(o: Operator, x, y: Num): string =
  let
    infix = case o.bOperation:
    of plus: "+"
    of minus: "-"
    of times: "*"
    of into: "/"
    of power: "^"
  "$1 $2 $3" % [$x, infix, $y]

proc stackOperatorExplain*(o: Operator, y = 0.0, x = 0.0): string =
  case o.nOperation:
    of showLast: "peek at stack"
    of exit: "quit"
    of showStack: "show stack"
    of clear: "clear stack"
    of dup: "duplicate $1" % $y
    of swapLast: "swap $1 and $2" % [$x, $y]
    of drop: "drop $1" % $y
    of popLast: "print and drop $1" % $y

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

proc eval*(op: Operator, x: Num): Num =
  ## Evaluation of unary operations.
  case op.uOperation:
    of squared:
      result = pow(x, x)
    of negative:
      result = -x
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

proc getOperatorsForStackLength*(length: int): seq[Operator] =
  if length >= 2:
    result = UNARY_OPERATORS & BINARY_OPERATORS & NULLARY_OPERATORS
  elif length == 1:
    result = UNARY_OPERATORS & NULLARY_OPERATORS.filterIt(it.minimumStackLength <= 1)
  else:
    result = NULLARY_OPERATORS.filterIt(it.minimumStackLength == 0)
