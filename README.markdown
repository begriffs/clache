## Overview

Clache runs [Lazy K](http://homepages.cwi.nl/~tromp/cl/lazy-k.html)
programs in the cloud. It memoizes every step of past reductions so
the more programs it runs, the faster it goes.

Consider it a kind of massively parallel virtual machine whose
bytecode is Lazy K.

## How to use

Point your web browser to

    http://clache.begriffsschrift.com/(lazy k program)

Where the [Lazy K](http://homepages.cwi.nl/~tromp/cl/lazy-k.html)
program is written in
[Unlambda](http://www.madore.org/~david/programs/unlambda/) syntax.
The web server will run the program and give you either the result,
in plain text, or a blank page if you exceeded the computation
limit.

## How to run real programs

Writing anything meaningful in Lazy K is hard. It is easier to write
purely functional programs in a language like Scheme and compile
that program into Lazy K. Clache does not support any form of runtime
output or side effects. A program's result must be contained in its
normal form.

This distribution contains an adaptation of a Scheme compiler and
programming framework written by [Ben
Rudiak-Gould](http://neuron2.net/www.math.berkeley.edu/benrg/index.html)
for the [2002 Esoteric Awards
competition](http://esoteric.voxelperfect.net/wiki/Essies#2002).

