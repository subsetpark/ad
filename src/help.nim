import op, stack, strutils, sequtils

proc `$`(o: Operator): string =
  let operation = case o.arity:
    of unary: $o.uOperation
    of binary: $o.bOperation
    of nullary: $o.nOperation
  $o.arity & " op " & operation

proc remainderStr(stack: Stack): string =
  if stack.len > 0: join(stack) & " "
  else: ""

proc explain*(o: Operator, stack: Stack): string =
  var
    x, y: string
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
  of nullary:
    remainder = stack
    remainderStr = ""

    if o.minimumStackLength == 0:
      explainStr = o.stackOperatorExplain()
    elif o.minimumStackLength == 1:
      y = $stack[^1]
      explainStr = o.stackOperatorExplain(y)
    else:
      y = $stack[^1]
      x = $stack[^2]
      explainStr = o.stackOperatorExplain(y, x)
  let
    name = $o & ":"
    explanation = (
      "[" & remainderStr & explainStr & "]"
    ).align(50 - name.len)

  name & explanation

proc explain*(stack: Stack): string =
  let eligibleOperators = getOperatorsForStackLength(stack.len)
  eligibleOperators.mapIt(it.explain(stack)).join("\n")
