import unittest, random, strutils, sequtils, options
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
  nums.mapIt(initStackObject(it))

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

    check 28 == lines.len

    for line in eligibleExplain.splitLines:
      check 50 == line.len

    eligibleExplain = @[1.0, 4.5].toStack.explain()
    lines = eligibleExplain.splitLines

    check 27 == lines.len

    eligibleExplain = @[4.5].toStack.explain()
    lines = eligibleExplain.splitLines

    check 18 == lines.len

    eligibleExplain = @[].toStack.explain()
    lines = eligibleExplain.splitLines

    check 6 == lines.len

  test "only variable operations are eligible with token argument":
    let
      eligibleExplain = @[initStackObject(4.0), initStackObject("foo")].explain()

      lines = eligibleExplain.splitLines
    check 9 == lines.len

  test "only unary operations are eligible with token as second argument":
    let
      eligibleExplain = @[initStackObject("foo"), initStackObject(4.0)].explain()

      lines = eligibleExplain.splitLines
    check 18 == lines.len

suite "types":

  setUp:
    let
      types1 = getTypes(@[initStackObject(4.0), initStackObject("foo")])
      types2 = getTypes(@[initStackObject(2.0), initStackObject("bar")])
      types3 = getTypes(@[initStackObject(4.0), initStackObject(5.0)])
      types4 = getTypes(@[initStackObject(4.0), initStackObject("foo"), initStackObject("bar")])
      plus_types = getOperator("+").get().getTypes()
      minus_types = getOperator("-").get().getTypes()
      def_types = getOperator("def").get().getTypes()

  test "test get types":
    check:
      getTypes(@[]).len == 0
      types1 == types2
      types1 != types3
      types1 != types4

  test "test get operator types":
    check:
      plus_types == minus_types
      plus_types != def_types

  test "check types":
    check:
      types1 != plus_types
      types1 == def_types
      def_types == types1
