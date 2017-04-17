import unittest, random, strutils
import "../src/stack", "../src/op", "../src/help"

suite "ad unit tests":
  setup:
    var stack: Stack = @[]

  test "add":
    stack.ingestLine("1 1 +")
    check stack == @[2.0]
  test "pow":
    stack.ingestLine("2 sqr")
    check stack == @[4.0]
  test "div":
    stack.ingestLine("6 4 /")
    check stack == @[1.5]
  test "clear":
    stack.ingestLine("1.0 c")
    check stack.len == 0

  test "accept floats":
    stack.ingestLine("1.0 7.5")
    check stack == @[1.0, 7.5]

  test "error handling":
    expect IndexError:
      stack.ingestLine("1 +")

    check stack.len == 0

    expect ValueError:
      stack.ingestLine("badToken")

    check stack.len == 0

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
      twoStack = @[3.0, 4.5]
      threeStack = @[1.0, 3.0, 4.5]

  test "float formatting":
    check "3 + 4.5" == PLUS.explain(3.0, 4.5)

  test "explain stack":
    check "binary op +:                         [1 (3 + 4.5)]" == PLUS.explain(threeStack)
    check "binary op +:                           [(3 + 4.5)]" == PLUS.explain(twoStack)
    check "unary op neg:                         [1 3 (-4.5)]" == NEGATIVE.explain(threeStack)
    check "stack op dup:                      [duplicate 4.5]" == DUP.explain(threeStack)

suite "eligible operators":

  test "get eligible operators":
    check 21 == getOperatorsForStackLength(3).len
    check 21 == getOperatorsForStackLength(2).len
    check 15 == getOperatorsForStackLength(1).len
    check 3 == getOperatorsForStackLength(0).len

  test "display help for all eligible operators":
    let
      eligibleExplain = @[1.0, 3.0, 4.5].explain()
      lines = eligibleExplain.splitLines

    check 21 == lines.len

    for line in eligibleExplain.splitLines:
      check 50 == line.len
