## Context-aware help display for operators.
import strutils, sequtils, options
import op, obj

proc explain(o: Operator, argStrings: seq[string]): string {. noSideEffect .}=
  ## Display help message for operator with arguments.
  const errorMsg = "Can't explain with given stack"
  let msg = case o.arity:
    of unary:
      if argStrings.len < 1:
        errorMsg
      else:
        case o.uOperation:
          of squared: "$1 ^ 2"
          of negative: "-$1"
          of absolute: "|$1|"
          of squareRoot: "square root of $1"
          of factorial: "$1!"
          of floor: "floor of $1"
          of ceiling: "ceiling of $1"
          of round: "round $1"
    of binary:
      if argStrings.len < 2:
        errorMsg
      else:
        "$1 " & $o.bOperation & " $2"
    of trinary:
      if argStrings.len < 3:
        errorMsg
      else:
        case o.tOperation:
          of toCond: "if $1 then $2 else $3"
    of nullary:
      if argStrings.len < o.minimumStackLength.int:
        errorMsg
      else:
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

proc explain(o: Operator, stack: Stack): string {. noSideEffect .}=
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
      r = stack[0..^argStrings.len + 1]
      remainderStr = if r.len > 0: join(r) & " " else: ""
    explanation = "[$1($2)]" % [remainderStr, explainStr]

  explanation = explanation.align(50 - name.len)
  result = name & explanation

proc explain*(stack: Stack): string =
  ## Generate explanatory text for all operators eligible for the
  ## current stack.
  OPERATORS.filterIt(it.typeCheck(stack)).mapIt(it.explain(stack)).join("\n")

proc explain*(stack: Stack, obj: StackObj): string =
  ## Explain the topmost object on the stack.
  let opToExplain = getOperator(obj.token)
  if opToExplain.isSome:
    result = opToExplain.get().explain(stack)
  else:
    result = "Don't know " & $obj
