import op, stack

proc explainStr*(o: StackOperator | BinaryOperator, stack: Stack): string =
  var
    y = stack[^1]
    x = stack[^2]

  o.explain(x, y)

proc remainderStr(stack: Stack): string =
  if stack.len > 0: join(stack) & " "
  else: ""

proc explain*(o: BinaryOperator, stack: Stack): string =
  var
    remainder = stack[0..stack.high - 2]

    explainStr = o.explainStr(stack)
    remainderStr = remainder.remainderStr

  "[" & remainderStr & "(" & explainStr & ")]"

proc explain*(o: UnaryOperator, stack: Stack): string =
  let
    x = stack[^1]
    remainder = stack[0..stack.high - 1]

    explainStr = o.explain(x)
    remainderStr = remainder.remainderStr

  "[" & remainderStr & "(" & explainStr & ")]"

proc explain*(o: StackOperator, stack: Stack): string =
  o.explainStr(stack)

