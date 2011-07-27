#!/usr/bin/env python

from google.appengine.ext import db
from google.appengine.ext import webapp
from google.appengine.ext.webapp import util
from google.appengine.api import memcache
import urllib2

class F(db.Model):
  """Computable frontier"""
  a = db.TextProperty(required=True)
  b = db.TextProperty(required=True)
  hash = db.IntegerProperty(required=True)

class Term(db.Model):
  """Normal terms"""
  cl = db.TextProperty(required=True)
  hash = db.IntegerProperty(required=True)

class MainHandler(webapp.RequestHandler):
  def get(self):
    t = urllib2.unquote(self.request.path[1:])
    self.handle(t)

  def post(self):
    t = urllib2.unquote(self.request.get('term'))
    self.handle(t)

  def handle(self, t):
    self.response.headers['Content-Type'] = 'text/plain'
    try:
      self.response.out.write(self.fr(t))
    except:
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
        raise BadArgumentError(t)
      balance += (1 if (t[offset+length] == '`') else -1)
      length += 1
      if balance <= 0:
        break
    return length


  def normal(self, t):
    if t[0] != '`':
      return True
    rs = Term.all().filter('hash =', hash(t)).fetch(10)
    for r in rs:
      if t == r.cl:
        return True
    return False


  def mark_normal(self, t):
    Term(cl = t, hash = hash(t)).put()


  def current_fr(self, t):
    rs = F.all().filter('hash =', hash(t)).fetch(10)
    for r in rs:
      if t == r.a:
        return r.b
    return None


  def memoize(self, a, b):
    memcache.add(a, b)
    F(a = a, b = b, hash = hash(a)).put()


  def fr(self, t):
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
      v = self.fr(u)
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
    l2 = self.fr(l)
    if l != l2:
      t2 = "`%s%s" % (l2, r)
      v = self.fr(t2)
      if v is not None:
        self.memoize(t, v)
      return v

    # then the other side
    r2 = self.fr(r)
    if r != r2:
      t2 = "`%s%s" % (l, r2)
      v = self.fr(t2)
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
