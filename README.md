Equipage
========

Equipage is the language that [Carriage][] might have been had I not been
so concerned about quoting.  (See "[Discussion: Quoting][]", below.)

Equipage is a purely concatenative language.  In this context, that means:

-   Every symbol in the language is associated with a function that
    takes stacks to stacks.
-   The meaning of a program text is the sequential composition of the
    functions associated with those symbols.

Thus, the meaning of a program is a function that takes stacks to stacks.

A stack may contain two kinds of values: unbounded integers, and functions
which take stacks to stacks.

Here is a table mapping the legal Equipage symbols to functions.

    !        apply
    ;        push *apply* onto the stack
    .        push *compose* onto the stack
    $        push *pop* onto the stack
    \        push *swap* onto the stack
    +        push *add* onto the stack
    -        push *sub* onto the stack
    %        push *sign* onto the stack
    ~        push *pick* onto the stack
    1        push *one* onto the stack
    <space>  nop

(`<space>` is intended to be, in fact, any whitespace.)

And here is an informal description of the functions named in the above table.

    *apply*:   pop a function off the stack and apply it to the rest of the stack
    *compose*: pop a function g, then a function h, off the stack, then push g.h
    *pop*:     pop a value off the stack and discard it
    *swap*:    pop a value a, then a value b, off the stack, then push a, then push b
    *add*:     pop a value a, then a value b, off the stack, then push a + b
    *sub*:     pop a value a, then a value b, off the stack, then push b - a
    *sign*:    pop a value off the stack, then push 1, 0, or -1, depending on its sign
    *pick*:    pop a value n off the stack, then copy the n'th element on the stack
               and push it onto the stack.  If n is negative, work from bottom of stack.
    *one*:     push the value 1 onto the stack
    *nop*:     do nothing to the stack.  (identity function.)

So.  Here is an example program text:

    1!$!

Given the above table, this program maps to the function

    push(one) ∘ apply ∘ push(pop) ∘ apply

The remainder of this document gives some examples of Equipage programs,
which also serve as test cases, and then discusses some aspects of the
language's design.

[Carriage]: http://esolangs.org/wiki/Carriage
[Discussion: Quoting]: #discussion-quoting

Equipage Tests
--------------

    -> Tests for functionality "Interpret Equipage Program"

    -> Functionality "Interpret Equipage Program" is implemented by
    -> shell command
    -> "(cd src && runhaskell Main.hs %(test-body-file))"

    -> Functionality "Interpret Equipage Program" is implemented by
    -> shell command
    -> "python3 impl/equipage.py/equipage.py %(test-body-file)"

one, apply
----------

Pushing numbers on the stack.  Note stacks are outputted top-to-bottom.

    1!
    ===> [1]

    1!1!
    ===> [1,1]

apply (deferred)
----------------

apply, as a function which is pushed onto the stack.

    1;!
    ===> [1]

add
---

Pop two values, then push their sum.

    1!1!+!
    ===> [2]

nop
---

Space and newline are both whitespace is nop.

    1!  1!1!+!
    1!1!+!1!+!
    ===> [3,2,1]

swap, pop
---------

Test `\` (swap) and `$` (pop).

    1!  1!1!+!  1!1!+!1!+!   \!$!
    ===> [3,1]

sub
---

Test `-`.

    1!  1!1!+!  1!1!+!1!+!   +!+!  1!-!
    ===> [5]

sign
----

Test `%` (sign).

    1!1!+!1!+!   %!
    ===> [1]

    1!1!-!1!-!   %!
    ===> [-1]

    1!1!-!       %!
    ===> [0]

pick
----

pick with a positive index picks from the top of the stack.

    1!  1!1!+!  1!1!+!1!+!    1!              ~!
    ===> [3,3,2,1]

    1!  1!1!+!  1!1!+!1!+!    1!1!+!          ~!
    ===> [2,3,2,1]

Picking from the very top of the stack has the effect of
duplicating the top stack element, so the idiom for `dup`
found in some other languages is `1!~!`.

pick with a negative index picks from the bottom of the stack.

    1!  1!1!+!  1!1!+!1!+!    1!1!-!1!-!      ~!
    ===> [1,3,2,1]

    1!  1!1!+!  1!1!+!1!+!    1!1!-!1!-!1!-!  ~!
    ===> [2,3,2,1]

pick with a zero index is zero, always.

    1!  1!1!+!  1!1!+!1!+!    1!1!-!          ~!
    ===> [0,3,2,1]

compose
-------

Compose pop and swap into a single function, and apply it.

    1!  1!1!+!  1!1!+!1!+!    \$.!    !
    ===> [3,1]

idiom: compose + pick + apply = call
------------------------------------

One idiom we forsee being used in Equipage is creating re-usable
functions using composition (on primitives and other functions)
and storing them at the bottom of the stack.  When one wishes to
use one of these functions, one would pick it using its known
(negative!) index, and apply it.

Create a function which pushes 2 onto the stack, and apply it
several times.

    11+.!.!
    1!1!-!1!-!~!;!
    1!1!-!1!-!~!;!
    1!1!-!1!-!~!;!
    ===> [2,2,2,<fn>]

(Yes, the code to fetch and apply the function, is longer than
the function itself.  So it goes.)

Create a function which doubles the value on the stack, and
apply it to 1 several times.

    1~+.!.!
    1!
    1!1!-!1!-!~!;!
    1!1!-!1!-!~!;!
    1!1!-!1!-!~!;!
    ===> [8,<fn>]

idiom: sign + pick = if
-----------------------

If we push a onto the stack, then b, then take the sign of a value,
then add one, then perform a pick, we will get a if the value was
positive and b if the value was zero.  If a and b are functions,
we can then apply the one we get.

In this example, a is 2, b is 3, and the value is zero.

    1!1!+!  1!1!+!1!+!
    1!1!-!
    %!1!+!~!
    ===> [3,3,2]

In this example, a is 2, b is 3, and the value is 4.

    1!1!+!  1!1!+!1!+!
    1!1!+!1!1!+!+!
    %!1!+!~!
    ===> [2,3,2]

It's possible to do a variant of this that picks from the bottom
of the stack.  We'll see how to do that in a more exhaustive test
below.

idiom: pick self + apply = loop
-------------------------------

'self' could be provided any number of ways, but if the function
that's currently executing is one of the common utility functions
from the bottom of the stack (first idiom), it's simplest to
just pick it like that.

This is an infinite loop.  For that reason, it's not written as a
Falderal test.

    11-1-~;.!.!.!.!.!.!
    1!1!-!1!-!~!;!

finally: if + loop = while loop
-------------------------------

Let's pop all values off the stack until we hit a zero, and then stop.

Pseudocode:
    
    def f1:
        duplicate value on stack
        if it is zero,
            stop
        else,
            pop it off
            f1

    push 2, 0, 2, 1
    f1

result should be `[0,2,<functions>]`.

Working out the pseudocode a bit:

    def f1:
        duplicate value on stack
        take the sign
        if it is zero,
            f3 (i.e. -3, pick, apply)
        else,
            f2 (i.e. -2, pick, apply)

    def f2:
        pop a value off the stack
        f1

    def f3:
        do nothing

    push 2, 0, 2, 1
    f1

Translating the pseudocode to Equipage:

    1~%1-1-1-~;
    .!.!.!.!.!.!.!.!.!.!

    $11-1-~;
    .!.!.!.!.!.!.!

    1$
    .!

    11+11-11+1
    .!.!.!.!.!.!.!.!.!
    !

    11-1-~;
    .!.!.!.!.!.!
    !

Let's test these parts in isolation a bit maybe.

Initial stack:

    11+11-11+1
    .!.!.!.!.!.!.!.!.!
    !
    ===> [1,2,0,2]

Nop:

    1$
    .!
    !
    ===> []

Run f1 initially (here, f1 is nop):

    1$
    .!
    
    11-1-~;
    .!.!.!.!.!.!
    !
    ===> [<fn>]

Everything but run.

    1~%1-1-1-~;
    .!.!.!.!.!.!.!.!.!.!
    
    $11-1-~;
    .!.!.!.!.!.!.!
    
    1$
    .!
    
    11+11-11+1
    .!.!.!.!.!.!.!.!.!
    !
    
    11-1-~;
    .!.!.!.!.!.!
    ===> [<fn>,1,2,0,2,<fn>,<fn>,<fn>]

The final result:

    1~%1-1-1-~;
    .!.!.!.!.!.!.!.!.!.!
    
    $11-1-~;
    .!.!.!.!.!.!.!
    
    1$
    .!
    
    11+11-11+1
    .!.!.!.!.!.!.!.!.!
    !
    
    11-1-~;
    .!.!.!.!.!.!
    !
    ===> [0,2,<fn>,<fn>,<fn>]

Discussion: Quoting
-------------------

Purely concatenative languages are almost embarassingly easy to interpret,
in a functional language:

*   **map** each symbol to a function
*   **compose** all those functions into a single function, in a **fold**
*   **apply** that single funciton

They are correspondingly easy to parse.  While most programming languages
require a context-free (or even context-sensitive) grammar to describe
their syntax, a purely concatenative language can be parsed with a regular
expression.  (And in Equipage's case, not even a complex one.)

But many, probably most, concatenative languages are not purely so; that is,
when specifying the program they incorporate some operations over and above
function composition.

One such useful thing is quoting — being able to nest subprograms within
a program, basically.  This seems to be how many of them deal with function
definitions.

But this nesting is exactly what requires the grammar to be context-free.

Carriage dealt with the issue of quoting by providing two interpretations
of the program text: one where it is all quoted, another where it is all
composed into a single function.  This is very esolang.  But was, I must
admit, somewhat unsatisfying (otherwise why would I be writing this.)

Equipage's approach is to have almost every instruction "already quoted".
That is, every symbol except `!` simply pushes a function onto the stack.
If you need to actually apply it, you have to do that "manually", by
following it with `!`.

This results in long chains of `x!y!z!` for some instructions x, y, and z,
and when you want to compose functions out of existing functions
especially, long chains of `.!.!.!` whose length must match the number of
composition operations involved in composing the constituent functions.

But if we're willing to add somewhat more complexity to the language,
we can make something that is virtually the equivalent of syntactic
quoting.

### EquipageQ ###

    -> Tests for functionality "Interpret EquipageQ Program"

    -> Functionality "Interpret EquipageQ Program" is implemented by
    -> shell command
    -> "(cd src && runhaskell Main.hs -Q %(test-body-file))"

    -> Functionality "Interpret EquipageQ Program" is implemented by
    -> shell command
    -> "python3 impl/equipage.py/equipage.py -Q %(test-body-file)"

We can define a minor dialect of Equipage, which we will call EquipageQ,
which lets us handle quoting in a syntactically nicer way.

EquipageQ adds a special value, MARKER, which can appear on the stack.
It also adds two new symbols to the vocabulary:

    (        push *mark* onto the stack
    )        push *define* onto the stack

(Note that, by having these symbols push functions onto the stack, we
are following the Equipage approach.  We will need to apply these with
`!` when we want to use them.)

The definition of those functions being

    *mark*:    push a MARKER onto the stack
    *define*:  keep popping functions off the stack, composing them,
               until a MARKER is popped; then push the resulting function
               onto the stack

That lets us write `wxyz.!.!.!` as `(!wxyz)!`, which is simpler,
because we don't need to be careful that the number of compose
operations matches the number of functions being composed.

And that lets us write the above program like:

    (! 1~%1-1-1-~; )!
    (! $11-1-~; )!
    (! 1$ )!
    (! 11+11-11+1 )!!
    (! 11-1-~; )!!
    ===> [0,2,<fn>,<fn>,<fn>]
