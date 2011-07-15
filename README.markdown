## Overview

Clache reduces combinatory logic terms and memoizes every step of
past reductions in a database. It reduces the terms either to normal
form, or to an arbitrary limit of work. In this way it records a
local "frontier" of computable knowledge. Conversely, clache can
losslessly and quickly compress a term by finding the shortest term
that reduces to the same place on the frontier as the original.

After perfecting the current version, I will investigate linking
Clache servers together into a P2P network for sharing frontiers.
A large network can act as a supercomputer for purely functional
programs. Read the Wiki to learn how to compile Scheme programs and
run them in Clache.

Runs on PHP and PostgreSQL.

## Usage

Point your web browser to
http://your-clache-server/?cl=combinatory-logic-term

Terms are written in the syntax of
[Unlambda](http://www.madore.org/~david/programs/unlambda) but are
restricted to the combinators S, K, and I.

The server will respond with the reduced term in plain text and
will provide reduction information in the HTTP headers.

 *header*    | *value*
------------ | --------------------------------------
X-Normal     | 1 if result is in normal form, else 0
X-Reductions | number of times reduced

On a successful reduction to normal form, the server issues an HTTP
200 result with long expiration Cache-Control, otherwise a 503 code.

## Installation

+ You will need a web server running [PHP](http://www.php.net/) 5.3
and [PostgreSQL](http://www.postgresql.org) 9.
+ Copy the clache source files to your web root.
+ Run `clweb.sql` in your database to create the necessary tables
and functions.
+ Change the database login credentials at the top of `index.php`
to match your own configuration.

