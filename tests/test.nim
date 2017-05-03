import unittest, random, strutils, sequtils
import "../src/stack", "../src/op"

proc ingestLine(stack: var Stack, s: string) =
  let tokens = s.split()
  stack.ingestLine(tokens)

proc values(stack: Stack): seq[float] =
  stack.mapIt(it.value)

suite "ad unit tests":
  setup:
    var stack: Stack = @[]

  test "add":
    stack.ingestLine("1 1 +")
    check stack.values == @[2.0]
  test "pow":
    stack.ingestLine("2 sqr")
    check stack.values == @[4.0]
  test "div":
    stack.ingestLine("6 4 /")
    check stack.values == @[1.5]
  test "clear":
    stack.ingestLine("1.0 c")
    check stack.len == 0

  test "accept floats":
    stack.ingestLine("1.0 7.5")
    check stack.values == @[1.0, 7.5]

proc toStack(nums: seq[float]): Stack =
  nums.mapIt(StackObj(isEval: true, value: it))

suite "stack display":

  setup:
    let
      PLUS = Operator(arity: binary, bOperation: plus)
      NEGATIVE = Operator(arity: unary, uOperation: negative)
      DUP = Operator(
        arity: nullary,
        nOperation: dup,
        minimumStackLength: 1
      )
      twoStack = @[3.0, 4.5].toStack
      threeStack = @[1.0, 3.0, 4.5].toStack

  test "float formatting":
    check "3 + 4.5" == PLUS.explain("3", "4.5")

  test "explain stack":
    check "binary op +:                         [1 (3 + 4.5)]" == PLUS.explain(threeStack)
    check "binary op +:                           [(3 + 4.5)]" == PLUS.explain(twoStack)
    check "unary op neg:                         [1 3 (-4.5)]" == NEGATIVE.explain(threeStack)
    check "stack op dup:                      [duplicate 4.5]" == DUP.explain(threeStack)

suite "eligible operators":

  test "get eligible operators":
    check 24 == getOperatorsForStackLength(3).len
    check 24 == getOperatorsForStackLength(2).len
    check 18 == getOperatorsForStackLength(1).len
    check 5 == getOperatorsForStackLength(0).len

  test "display help for all eligible operators":
    let
      eligibleExplain = @[1.0, 3.0, 4.5].toStack.explain()
      lines = eligibleExplain.splitLines

    check 24 == lines.len

    for line in eligibleExplain.splitLines:
      check 50 == line.len
