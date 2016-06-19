let doc = """
Simple Reverse Polish Calculator.

Usage:
  ad <exp>...
"""
import docopt, strutils, math

type 
  Operator = enum
    Plus = "+"
    Minus = "-"
    Times = "*"
    Into = "/"
    Noop = ""
  Stack = seq[float]

proc newOperator(t: string): Operator = 
  case t
    of "+": Plus
    of "-": Minus
    of "*": Times
    of "/": Into
    else: Noop

proc eval(op: Operator; x, y: float): float =
  case op:
    of Plus:
      x + y
    of Minus:
      x - y
    of Times:
      x * y
    else:
      x / y 

proc operate(stack: var Stack, op: Operator): void =
  let y = stack.pop()
  let x = stack.pop()
  stack.add(eval(op, x, y))

proc ingest(stack: var Stack, t: string): void =
  if t.isDigit: 
    stack.add(parseFloat t)
  else:
    stack.operate(newOperator t)

proc print(stack: var Stack): void = 
  let r = stack[stack.high]
  if fmod(r, 1.0) == 0:
    echo $int(r)
  else:
    echo r

var stack: Stack = @[]

let args = docopt(doc, version="AD 1")

try:
  for t in @(args["<exp>"]):
    stack.ingest(t)

  if len(stack) > 0:
    stack.print()
  if len(stack) > 1:
    echo "Elements remaining: $1" % $stack[..(stack.high-1)]
except IndexError:
  quit "Imbalanced input."


