import unittest, random, stack

suite "ad unit tests":
  setup:
    var stack: Stack = @[]

  test "add":
    check stack.ingestLine("1 1 +") == @[2.0]
  test "pow":
    check stack.ingestLine("2 sqr") == @[4.0]
  test "div":
    check stack.ingestLine("6 4 /") == @[1.5]
  test "clear":
    check stack.ingestLine("1.0 c") == newSeq[float]()

  test "accept floats":
    check stack.ingestLine("1.0 7.5") == @[1.0, 7.5]

  test "error handling":
    expect IndexError:
      stack = stack.ingestLine("1 +")

    check stack.len == 0

    expect ValueError:
      stack = stack.ingestLine("badToken")

    check stack.len == 0
