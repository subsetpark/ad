## Token parsing module.
import options, tables, math, strutils
import op

const QUOTE* = {'\'', '`'}

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
  let floatValue = parseFloat(t)

  if floatValue.isSome:
    result = obj(initStackObject(floatValue.get()))

  elif t in locals:
    result = obj(initStackObject(locals[t]))

  else:
    let maybeOperator = getOperator(t)
    if maybeOperator.isSome:
      result = op(maybeOperator.get())
    else:
      case t[0]
      of QUOTE:
        result = obj(initStackObject(t[1..t.high]))
      else:
        raise newException(ValueError, "Unrecognized token: $1" % t)
