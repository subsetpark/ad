let doc = """
Simple Reverse Polish Calculator.

Usage:
  ad <exp>...
"""
import docopt, strutils, future

type 
  Operator = enum
    Plus = "+"
    Minus = "-"
  ElementKind = enum
    ekOperator, ekNumber
  Element = object
    case kind: ElementKind
    of ekOperator:
      operator: Operator
    of ekNumber:
      value: int

proc getElement(t: string): Element = 
  if t.isDigit: 
    Element(kind: ekNumber, value: parseInt(t))
  else:
    let operator= case t
      of "+": Plus
      of "-": Minus
      else: Plus
    Element(kind: ekOperator, operator: operator)

proc getElement(n: int): Element = Element(kind: ekNumber, value: n)

proc eval(op, x, y: Element): int =
  case op.operator:
    of Plus:
      x.value + y.value
    of Minus:
      x.value - y.value


proc ingest(stack: var seq[Element], e: Element): seq[Element] =
  result = stack
  if e.kind == ekOperator:
    let y = pop(stack)
    let x = pop(stack)
    stack.add(getElement eval(e, x, y))
  else:
    stack.add(e)


var 
  stack = newSeq[Element]()

let args = docopt(doc, version="AD 1")

try:
  for t in @(args["<exp>"]):
    discard stack.ingest(getElement t)

  if len(stack) > 0:
    echo $stack.pop().value
  if len(stack) > 0:
    echo "Elements remaining: $1" % [$lc[e.value | (e <- stack), int]]
except IndexError:
  echo "Imbalanced input."


