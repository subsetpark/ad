## Token parsing module.
import options, tables, math, strutils
import op, obj

const QUOTE = {'\'', '`'}

proc parseNum(t: string): Option[Num] =
  const specialTokens = ["."]
  case t
  of "e": some E.toNum
  of "pi": some PI.toNum
  of "tau": some TAU.toNum
  of specialTokens: none(Num)
  else:
    try:
      some strutils.parseFloat(t).toNum
    except ValueError:
      none(Num)

type OperatorOrObj* = object
  case isObj*: bool
  of true:
    obj*: StackObj
  of false:
    op*: Operator

proc op(o: Operator): OperatorOrObj {.inline.} =
  result = OperatorOrObj(isObj: false, op: o)
proc obj(o: StackObj): OperatorOrObj {.inline.} =
  result = OperatorOrObj(isObj: true, obj: o)

proc parseToken*(locals: Table[string, Num], t: string ): OperatorOrObj =
  ## Evaluate a token and return the resulting object, either a stack object or
  ## an operator.
  if t[0] in QUOTE:
    return obj(initStackObject(t[1..t.high]))

  let numValue = parseNum(t)
  if numValue.isSome:
    return obj(initStackObject(numValue.get()))

  if t in locals:
    return obj(initStackObject(locals[t]))

  let maybeOperator = getOperator(t)
  if maybeOperator.isSome:
    return op(maybeOperator.get())
  # Fall through.
  raise newException(ValueError, "Unrecognized token: $1" % t)
