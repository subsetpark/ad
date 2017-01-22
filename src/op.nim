import tables

type 
  BinaryOperator* = enum
    plus
    minus
    times
    into
    power
  UnaryOperator* = enum
    squared
    negative
    absolute
    squareRoot
    factorial
    floor
    ceiling
    round
  StackOperator* = enum
    showLast
    showStack
    clear
    exit
  NullOperator* = enum
    null

const binaryTokens* = [("+", plus), 
                      ("-", minus), 
                      ("*", times), 
                      ("x", times),
                      ("/", into), 
                      ("^", power), 
                      ("**", power), 
                      ("pow", power)].toTable
const unaryTokens* = [("sqr", squared), 
                     ("abs", absolute), 
                     ("neg", negative),
                     ("sqrt", squareRoot),
                     ("!", factorial),
                     ("fl", floor),
                     ("ceil", ceiling),
                     ("rnd", round)].toTable
const stackTokens* = [("p", showLast), 
                     ("peek", showLast), 
                     ("q", exit), 
                     ("quit", exit),
                     ("s", showStack),
                     ("show", showStack),
                     ("stack", showStack),
                     ("c", clear),
                     ("clear", clear)].toTable

