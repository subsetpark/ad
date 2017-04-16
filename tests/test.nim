import unittest, random
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

  test "float formatting":
    check "3 + 4.5" == boPlus.explain(3.0, 4.5)

  test "explain stack":
    check "[1 (3 + 4.5)]" == boPlus.explain(@[1.0, 3.0, 4.5])
    check "[(3 + 4.5)]" == boPlus.explain(@[3.0, 4.5])
    check "[1 3 (-4.5)]" == uoNegative.explain(@[1.0, 3.0, 4.5])
    check "dup 4.5" == soDup.explain(@[1.0, 3.0, 4.5])
