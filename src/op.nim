import options, strutils, math
import typetraits

type
  BinaryOperator* = enum
    boPlus
    boMinus
    boTimes
    boInto
    boPower
  UnaryOperator* = enum
    uoSquared
    uoNegative
    uoAbsolute
    uoSquareRoot
    uoFactorial
    uoFloor
    uoCeiling
    uoRound
  StackOperator* = enum
    soShowLast
    soShowStack
    soClear
    soExit
    soDup
    soSwap
  NullOperator* = enum
    null
  Num* = float

proc `$`(n: Num): string =
  ## Overridden toString operator. Numbers are stored as floats, but will be
  ## displayed as integers if possible.
  if fmod(n, 1.0) == 0:
    $int(n)
  else:
    system.`$` n

proc getBinaryOperator*(t: string): Option[BinaryOperator] =
  case t
  of "+": some(boPlus)
  of "-": some(boMinus)
  of "x", "*": some(boTimes)
  of "/": some(boInto)
  of "^", "**", "pow": some(boPower)
  else: none(BinaryOperator)

proc getUnaryOperator*(t: string): Option[UnaryOperator] =
  case t
  of "sqr": some(uoSquared)
  of "abs": some(uoAbsolute)
  of "neg": some(uoNegative)
  of "sqrt": some(uoSquareRoot)
  of "!", "fac": some(uoFactorial)
  of "fl": some(uoFloor)
  of "ceil": some(uoFloor)
  of "rnd": some(uoRound)
  else: none(UnaryOperator)

proc getStackOperator*(t: string): Option[StackOperator] =
  case t
  of "p", "peek": some(soShowLast)
  of "q", "quit": some(soExit)
  of "s", "show", "stack": some(soShowStack)
  of "c", "clear": some(soClear)
  of "d", "dup": some(soDup)
  of "sw", "swap": some(soSwap)
  else: none(StackOperator)

proc explain*(o: BinaryOperator, x, y: Num): string =
  let
    infix = case o:
    of boPlus: "+"
    of boMinus: "-"
    of boTimes: "*"
    of boInto: "/"
    of boPower: "^"
  "$1 $2 $3" % [$x, infix, $y]

proc explain*(o: UnaryOperator, x: Num): string =
  let x = $x
  case o:
    of uoSquared: "$1 ^ 2" % x
    of uoNegative: "-$1" % x
    of uoAbsolute: "|$1|" % x
    of uoSquareRoot: "sqrt $1" % x
    of uoFactorial: "$1!" % x
    of uoFloor: "floor $1" % x
    of uoCeiling: "ceil $1" % x
    of uoRound: "round $1" % x

proc explain*(o: StackOperator, x, y: Num): string =
  let
    x = $x
    y = $y
  case o:
    of soShowLast: "peek at stack"
    of soExit: "quit"
    of soShowStack: "show stack"
    of soClear: "clear stack"
    of soDup: "dup $1" % y
    of soSwap: "swap $1 and $2" % [x, y]
