AD
__

The RPN Calculator With An Extremely Clever Name
=================================================

    ``ad``, as in, *after* ``bc``, but also as in the first two letters of the common
    mathematical operation, *add*.

Usage
=====

``ad`` is a stack-based Reverse Polish Notation calculator application. If you're familiar with the command-line UNIX application ``dc``, you'll understand how it works. There's also ``bc``, which is not RPN and therefore not particularly germane, but is necessary for the pun to work.

Here's a sample line of ``dc`` input from Wikipedia:

::

   12 _3 4 ^ + 11 / v 22 -
   p 

This is interpreted as a series of commands for manipulating a stack of numbers, where values are *pushed* onto the top of the stack and then *popped* off the top of the stack later to be operated on, with the result being pushed back onto the top of the stack:

1. Push 12.
2. Push -3.
3. Push 4.
4. Pop 4 and -3, Raise -3 to the 4th power and push the result.
5. Pop the result of (4) and 12, add them, and push the result.
6. Push 11.
7. Pop 11 and the result of (5), divide (5) by 11 and push the result.
8. Pop (7), calculate the square root, and push the result.
9. Push 22.
10. Pop 22, pop (8), subtract 22 from (8).

Finally, the ``p`` command prints the top of the stack, which is now occupied by the result of the whole expression.

The same sequence of operations in ``ad`` is:

::
    
    12 -3 4 ^ + 11 / sqrt 22 -
    p

Where ``^`` can also be written as ``**``.

Inputs
======

``ad`` accepts commands on the command line or through stdin.

Command Line Arguments
######################

Shell operators can be individually escaped or the whole input can be quoted.

::

    ; ad 12 -3 4 \^ + 11 / sqrt 22 -
    -19.09232989241464
    ; ad '12 -3 4 ^ + 11 / sqrt 22 -'
    -19.09232989241464

Pipes
#####

:: 

    ; echo '12 -3 4 ^ + 11 / sqrt 22 -' | ad
    -19.09232989241464
    
Interactive mode
################

By calling ``ad`` with no arguments, the user can enter the interactive shell. 

::

    ; ad
    > 12 -3 4 ^ + 11 / sqrt 22 -
    > p
    -19.09232989241464
    > 
    
Entering the ``q`` command in the shell will display the topmost element of the stack and quit.

The stack will be represented as a space-separated list of number values between two square brackets, with the bottom-most/lowest element on the left.

There are some commands designed to make interactive use of ``ad`` slightly more powerful and convenient. Among them is the ``??`` or ``explain-all`` command, which we can also use to give an overview of the other commands available:

::

    ; ad
    > 12 -3 4 ^ + 11 2.5
    > ??
    stack op peek:                     [peek at stack]
    stack op quit:                              [quit]
    stack op show:                        [show stack]
    stack op clear:                      [clear stack]
    stack op dup:                      [duplicate 2.5]
    stack op swap:                   [swap 11 and 2.5]
    stack op drop:                          [drop 2.5]
    stack op pop:                 [print and drop 2.5]
    stack op ?:                          [explain 2.5]
    stack op ??:                       [explain stack]
    stack op hist:                      [show history]
    stack op =:                     [define 2.5 as 11]
    stack op undef:         [remove definition of 2.5]
    stack op vars:               [display variables]
    unary op sqr:                    [93 11 (2.5 ^ 2)]
    unary op abs:                      [93 11 (|2.5|)]
    unary op neg:                       [93 11 (-2.5)]
    unary op sqrt:        [93 11 (square root of 2.5)]
    unary op !:                         [93 11 (2.5!)]
    unary op floor:             [93 11 (floor of 2.5)]
    unary op ceil:            [93 11 (ceiling of 2.5)]
    unary op round:                [93 11 (round 2.5)]
    binary op +:                       [93 (11 + 2.5)]
    binary op -:                       [93 (11 - 2.5)]
    binary op *:                       [93 (11 * 2.5)]
    binary op /:                       [93 (11 / 2.5)]
    binary op ^:                       [93 (11 ^ 2.5)]
    binary op >:                       [93 (11 > 2.5)]
    binary op <:                       [93 (11 < 2.5)]
    binary op ==:                     [93 (11 == 2.5)]
    trinary op cond:        [(if 93 then 11 else 2.5)]
    > 

Binary Operations
*****************

``+``, ``-``, ``*``, ``/``, ``^``: Ordinary arithmetic operations.

Unary Operations
****************

``sqr``, ``abs``, ``neg``, ``sqrt``, ``!``, ``floor``, ``ceil``, ``round``: Mathematic operations on the topmost element.

Stack Operations
****************

``peek``, ``show``, ``clear``, ``dup``, ``swap``, ``drop``, ``pop``: These commands manipulate the stack, by printing it or mutating it. 

``hist``: Displays the results of each operation so far.

::

    > 12 -3 4 ^ + 11 2.5
    > hist
    2: 93
    1: 81

Conditional Operations
**********************

``<``, ``>``, ``==``: Evaluates relations between the top two elements on the stack. Pushes a ``1`` for true and a ``0`` for false.

``cond``: Evaluates the antepenultimate element on the stack for truth (0 is false, everything else is true) and returns the penultimate element to the stack if true, otherwise the ultimate one.

Variable Operations
*******************

Any command that starts with a ````` or ``'`` will be treated as a symbol rather than as a value. This allows the user to define variables. The unevaluated symbol will be pushed to the top of the stack, and then can be used as the argument to the ``=``/``def`` command.

::

    > 36 4 + 'lucky-number =
    > s
    []
    > 

(``s`` is short for ``show``) ``lucky-number`` is now defined as the result of ``36 4 +``.

::

    > lucky-number 2 *
    > .
    80
    > 

(``.`` is short for ``pop``)

``vars``: Display all currently assigned variables.

::

    > vars
    lucky-number: 40
    
``undef``: Remove the definition of a variable.

::

    > `lucky-number undef
    > vars
    > lucky-number
    Unrecognized token: lucky-number
    
Quoting a symbol can also be used with the ``?`` command, which takes a quoted operator name as its argument.

``?``: Explain an operator.

::

    > 4 5
    > '+ ?
    binary op +:                             [(4 + 5)]

How to Get it
=============

``ad`` is written in the Nim programming language. The easiest way to install is to use the nimble package manager:

::

    nimble install ad
