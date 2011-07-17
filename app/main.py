#!/usr/bin/env python

from google.appengine.ext import db
from google.appengine.ext import webapp
from google.appengine.ext.webapp import util
from google.appengine.api import memcache
import urllib2

class F(db.Model):
  """Computable frontier"""
  a = db.StringProperty(required=True)
  b = db.StringProperty(required=True)

class Term(db.Model):
  """Normal terms"""
  cl = db.StringProperty(required=True)

class MainHandler(webapp.RequestHandler):
  def get(self):
    self.response.headers['Content-Type'] = 'text/plain'
    t = urllib2.unquote(self.request.path[1:])
    try:
      self.response.out.write(self.fr(t, 300))
    except ValueException:
      self.error(400) # bad request


  def cached(self, a):
    b = memcache.get(a)
    if b is not None:
      return b
    else:
      b = self.current_fr(a)
      if b is not None:
        memcache.add(a, b)
      return b


  def eot(self, t, offset):
    balance = 1
    length  = 0
    max     = len(t)
    while True:
      if offset+length >= max:
        raise ValueException
      balance += (1 if (t[offset+length] == '`') else -1)
      length += 1
      if balance <= 0:
        break
    return length


  def normal(self, t):
    if t[0] != '`':
      return True
    q = Term.all(keys_only = True).filter('cl =', t)
    return q.count(1) > 0


  def mark_normal(self, t):
    Term(cl = t).put()


  def current_fr(self, t):
    rs = F.all().filter('a =', t).fetch(1)
    for r in rs:
      return r.b
    return None


  def memoize(self, a, b):
    memcache.add(a, b)
    F(a = a, b = b).put()


  def fr(self, t, d):
    # if depth limit reached
    if d < 1:
      return None

    # if t is cached, we're done
    u = self.cached(t)
    if u is not None:
      return u

    # check for reduction by basic rules
    if t.startswith('`i'):
      u = t[2:]
    elif t.startswith('``k'):
      u = t[3:3+self.eot(t, 3)]
    elif t.startswith('```s'):
      x  = self.eot(t, 4)
      sx = t[4:4+x]
      y  = self.eot(t, 4+x)
      sy = t[4+x:4+x+y]
      z  = self.eot(t, 4+x+y)
      sz = t[4+x+y:4+x+y+z]
      u  = "``%s%s`%s%s" % (sx, sz, sy, sz)

    # if it reduced a step then keep it going and memoize
    if u is not None:
      v = self.fr(u, d - 1)
      if v is not None:
        self.memoize(t, v)
      return v

	# if it did not reduce, maybe it is known to be normal
    if self.normal(t):
      return t

    # well, time to divide and conquer
    split = self.eot(t, 1)
    l = t[1:1+split]
    r = t[1+split:]

    # leftmost, outermost first
    l2 = self.fr(l, d - 1)
    if l != l2:
      t2 = "`%s%s" % (l2, r)
      v = self.fr(t2, d - 1)
      if v is not None:
        self.memoize(t, v)
      return v

    # then the other side
    r2 = self.fr(r, d - 1)
    if r != r2:
      t2 = "`%s%s" % (l, r2)
      v = self.fr(t2, d - 1)
      if v is not None:
        self.memoize(t, v)
      return v

    if self.normal(l) and self.normal(r):
      self.mark_normal(t)

    return t


def main():
  application = webapp.WSGIApplication([('/.*', MainHandler)], debug=True)
  util.run_wsgi_app(application)


if __name__ == '__main__':
  main()
