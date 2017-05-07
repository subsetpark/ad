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

  test "explain stack":
    let
      eligibleExplain = @[1.0, 3.0, 4.5].toStack.explain()
      allLines = eligibleExplain.splitLines

      explainLines = [
        "binary op +:                         [1 (3 + 4.5)]",
        "unary op neg:                         [1 3 (-4.5)]",
        "stack op dup:                      [duplicate 4.5]"
      ]
    for line in explainLines:
      check line in allLines

suite "eligible operators":

  test "display help for all eligible operators":
    var
      eligibleExplain = @[1.0, 3.0, 4.5].toStack.explain()
      lines = eligibleExplain.splitLines

    check 31 == lines.len

    for line in eligibleExplain.splitLines:
      check 50 == line.len

    eligibleExplain = @[1.0, 4.5].toStack.explain()
    lines = eligibleExplain.splitLines

    check 30 == lines.len

    eligibleExplain = @[4.5].toStack.explain()
    lines = eligibleExplain.splitLines

    check 20 == lines.len

    eligibleExplain = @[].toStack.explain()
    lines = eligibleExplain.splitLines

    check 6 == lines.len
