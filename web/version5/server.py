#!/usr/bin/python

from google.appengine.ext import webapp
from google.appengine.ext.webapp.util import run_wsgi_app

# This just redirects the raw domain to the main static web page.
class MainPage(webapp.RequestHandler):
  def get(self):
    self.redirect("/index.html#intro?pause=true")
    # self.response.headers['Content-Type'] = 'text/plain'
    # self.response.out.write('Hi, there.\n')
    # self.response.out.write('This site is still under construction.\n')
    # self.response.out.write('I hope to have something public by Summer, 2013.\n')

# This tells robots I'm not yet ready for prime time.
class RobotPage(webapp.RequestHandler):
  def get(self):
    self.response.headers['Content-Type'] = 'text/plain'
    self.response.out.write('User-agent: *\n')
    self.response.out.write('Disallow:\n')

# This is just mucking about....
class HelloPage(webapp.RequestHandler):
  def get(self, subpage):
    self.response.headers['Content-Type'] = 'text/plain'
    self.response.out.write('Hello, World! Subpage = '+subpage)


application = webapp.WSGIApplication([('/', MainPage),
                                      ('/hello/(.*)', HelloPage),
                                      ('/robots.txt', RobotPage)],
                                     debug=True)

# log.warning("This is just before calling main.")

def main():
  run_wsgi_app(application)

if __name__ == "__main__":
  main()
