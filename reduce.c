#include <stdio.h>
#include <stdlib.h>
#include <string.h>

unsigned int eot(const char* s, unsigned int offset);
const char* reduce(const char* t);

int main(int argc, char** argv) {
	char* t = (char*)reduce(argv[1]);
	// because of memory sharing, the remains of longer
	// terms may still exist at the end of the string
	// so we truncate the string at the right place
	t[eot(t, 0)] = '\0';
	puts(t);
	return 0;
}

// eot = end of term: returns length of next term
// after offset, or zero on syntax error
unsigned int eot(const char* s, unsigned int offset) {
	unsigned int balance = 1;
	for(; s[offset] && balance > 0; offset++) {
		balance += (s[offset] == '`' ? 1 : -1);
	}
	return (balance > 0) ? 0 : offset;
}

// the ugly land of magic numbers and memcpy
const char* reduce(const char* t) {
	int x, y, z, sx, sy, sz;
	char *s;
	const char *l, *r;
	// if t is a leaf
	if(t[0] != '`')                { return t; }
	// the three combinator reduction rules
	if(strncmp(t, "`i", 2) == 0)   { return reduce(t+2); }
	if(strncmp(t, "``k", 3) == 0)  { return reduce(t+3); }
	if(strncmp(t, "```s", 4) == 0) {
		// Sxyz -> ``xz`yz
		x    = eot(t, 4);
		y    = eot(t, x);
		z    = eot(t, y);
		sx   = x-4;
		sy   = y-x;
		sz   = z-y;
		s    = malloc(3 + sx + sy + 2*sz);
		s[0] = s[1] = s[2+sx+sz] = '`';
		memcpy (s+2,          t+4, sx);
		memcpy (s+2+sx,       t+y, sz);
		memcpy (s+3+sx+sz,    t+x, sy);
		strncpy(s+3+sx+sz+sy, t+y, sz);
		return reduce(s);
	}

	// try and reduce leftmost applicand
	sx = eot(t, 1) - 1;
	l  = reduce(t+1);
	sz = eot(l, 0);
	y  = eot(t, 1+sx);
	sy = y - (1+sx);
	if(strncmp(t+1, l, sx < sz ? sx : sz) != 0) {
		s = malloc(1 + sz + sy);
		s[0] = '`';
		memcpy (s+1,    l,   sz);
		strncpy(s+1+sz, t+1+sx, sy);
		return reduce(s);
	}

	// if that did nothing, try right applicand
	r = reduce(t+1+sx);
	sz = eot(r, 0);
	if(strncmp(t+1+sx, r, sy < sz ? sy : sz) != 0) {
		s = malloc(1 + sx + sz);
		s[0] = '`';
		memcpy (s+1,    t+1, sx);
		strncpy(s+1+sx, r,   sz);
		return reduce(s);
	}

	// t must be in normal form, we're done
	return t;
}
