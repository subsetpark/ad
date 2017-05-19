## Token parsing module.
import options, tables, math, strutils
import op, obj

const QUOTE = {'\'', '`'}

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

type OperatorOrObj* = object
  case isObj*: bool
  of true:
    obj*: StackObj
  of false:
    op*: Operator
proc op(o: Operator): OperatorOrObj {.inline.} =
  result.isObj = false
  result.op = o
proc obj(o: StackObj): OperatorOrObj {.inline.} =
  result.isObj = true
  result.obj = o

proc parseToken*(locals: Table[string, float], t: string ): OperatorOrObj =
  ## Evaluate a token and return the resulting object, either a stack object or
  ## an operator.
  if t[0] in QUOTE:
    return obj(initStackObject(t[1..t.high]))

  let floatValue = parseFloat(t)
  if floatValue.isSome:
    return obj(initStackObject(floatValue.get()))

  if t in locals:
    return obj(initStackObject(locals[t]))

  let maybeOperator = getOperator(t)
  if maybeOperator.isSome:
    return op(maybeOperator.get())
  # Fall through.
  raise newException(ValueError, "Unrecognized token: $1" % t)