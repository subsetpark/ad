## Module for the basic object type.
import math, strutils, sequtils

type
  Num* = float
  ObjectType* = enum
    otSymbol = "Symbol"
    otNum = "Number"
  Types* = seq[ObjectType]
  StackObj* = object
    case objectType: ObjectType
    of otNum:
      value*: Num
    of otSymbol:
      token*: string
  Stack* = seq[StackObj]
  Arguments* = seq[StackObj]

proc `$`*(n: Num): string {. noSideEffect .}=
  ## Display whole numbers without a decimal.
  if fmod(n, 1.0) == 0:
    $int(n)
  else:
    system.`$` n
proc `$`*(o: StackObj): string {. noSideEffect .}=
  ## Display a stack object. Display whole numbers as integers,
  ## unevaluated symbols as tokens.
  if o.objectType == otNum:
    $o.value
  else:
    o.token

proc join*[T](ts: T): string =
  ## Concatenate the sequence with spaces.
  strutils.join(ts, " ")
proc `$`*(types: Types): string = "(" & join(types) & ")"
proc `$`*(stack: Stack): string = "[" & join(stack) & "]"

proc initStackObject*(val: Num): StackObj {. noSideEffect .}=
  ## Create a new stack number object.
  result.objectType = otNum
  result.value = val
proc initStackObject*(t: string): StackObj {. noSideEffect .}=
  ## Create a new stack symbol object.
  result.objectType = otSymbol
  result.token = t

proc getTypes*(args: Arguments): Types {. noSideEffect .}=
  ## Get the types for a set of command arguments.
  args.mapIt(it.objectType)
