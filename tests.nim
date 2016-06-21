import unittest, random

suite "ad unit tests":
  test "smoke test":
    var stack: Stack = @[]
    check stack.ingestLine("1 1 +") == @[2.0]

  test "error handling":
    var stack: Stack = @[]
    expect IndexError:
      stack = stack.ingestLine("1 +")

    check len(stack) == 0

    expect ValueError:
      stack = stack.ingestLine("badToken")

    check len(stack) == 0

