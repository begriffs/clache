## Overview

Clache reduces [Lazy K](http://homepages.cwi.nl/~tromp/cl/lazy-k.html)
programs on the command line.

This is a dirt simple implementation in C with an emphasis on brute
speed. No clever algorithms, no structures, just pointer arithmetic
and memcpy. One of the sacrifices for simplicity is that the program
leaks memory. Strings are shared where possible, but no memory is
ever freed. This is OK when the program is run to do a one-shot
reduction and then terminated.

## How to use

Point your web browser to

    ./reduce '[lazy-k-program]'

Where the [Lazy K](http://homepages.cwi.nl/~tromp/cl/lazy-k.html)
program is written in
[Unlambda](http://www.madore.org/~david/programs/unlambda/) syntax.
For instance,

	./reduce '```skki'

