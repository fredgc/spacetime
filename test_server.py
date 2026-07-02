#!/usr/bin/python

# Use this to tell if appengine is on dev server:
# import os
# DEV = os.environ['SERVER_SOFTWARE'].startswith('Development')
# if(OldVersion):
#     from my.package.location.A import A
# else:
#     from new.package.location.A import A
# try:
#     import json
# except ImportError:
#     import simplejson as json

import os
import operator
import subprocess
from subprocess import call
import threading
import time
import sys
import BaseHTTPServer
from BaseHTTPServer import BaseHTTPRequestHandler,HTTPServer
from SimpleHTTPServer import SimpleHTTPRequestHandler
from SocketServer import ThreadingMixIn
import urlparse
import re
import mimetypes

global recorder
global sound_filename
recorder = 0;
sound_filename = "default"

class MyHandler(BaseHTTPRequestHandler):

  def do_GET(self):
    print "GET = ", self.path
    m = re.search( r'start/(.*)', self.path)
    if m:
      global sound_filename
      sound_filename = m.group(1)
      print "Starting recording "+sound_filename
      self.send_response(200)
      self.send_header('Content-type', 'text/txt')
      self.end_headers()
      self.wfile.write("start")
      global recorder
      recorder = subprocess.Popen(['arecord', '-t', 'wav',
                                   '-f', 'S16_LE', # 16 bit.
                                   '-r', '12',     # 12 kHz.
                                   '-d', 'hw',     # Use hardware recording.
                                   'lessons/'+sound_filename+'.wav'], shell=False)
    elif re.search( r'stop', self.path):
      print "Stoping recording."
      recorder.terminate();
      print "Done stop recording."
      global sound_filename
      subprocess.call(['lame',
                      'lessons/' + sound_filename + '.wav',
                      'lessons/' + sound_filename + '.mp3'])
      subprocess.call(['chmod', 'og+r',
                       'lessons/' + sound_filename + '.mp3'])
      self.send_response(200)
      self.send_header('Content-type', 'text/txt')
      self.end_headers()
      self.wfile.write("stop")
    elif re.search( r'favicon.ico', self.path):
      linestring = open('images/favicon.ico', 'r').read()
      self.send_response(200)
      self.send_header('Content-type', 'image/x-icon')
      self.end_headers()
      self.wfile.write(linestring)
    else:
      print "HTML: ", self.path
      if self.path == "/":
        self.path = "/index.html"
      dirname = os.path.abspath(os.path.dirname("./" + self.path))
      print "Full path is ", os.path.abspath("./" + self.path)
      print "dir name is ", dirname

      if re.search("lessons", dirname):
        raw = "." + re.sub("lessons/", "raw-lessons/", self.path)
        if os.path.isfile(raw):
          path_time = os.path.getmtime("." + self.path)
          raw_time = os.path.getmtime(raw)
          if raw_time > path_time:
            print "--- RAW FILE CHANGED.  REMAKING."
            subprocess.call("make ."+self.path, shell=True)

      linestring = open('.' + self.path, 'r').read()
      future = ('<li> <input id="show_future" type="checkbox" '
                + 'onclick="windowResize();"'
                + ' checked="checked"'
                + '>Show Future</li>')
      linestring = linestring.replace('<!-- future -->', future)
      linestring = linestring.replace('id="(page\d*)">', 'id="\1">\1')
      linestring = linestring.replace('debug_sounds = ""',
                                      'debug_sounds = "http://localhost:80/relativity/"')
      # Convert to off line testing -- so it works when I'm on the bus.
      linestring = linestring.replace('//ajax.googleapis.com/ajax/libs/jquery/2.0.3/jquery.min.js',
                                      '/cached/jquery.min.js')
      linestring = linestring.replace('//ajax.googleapis.com/ajax/libs/jqueryui/1.10.3/jquery-ui.min.js',
                                      '/cached/jquery-ui.min.js')
      linestring = linestring.replace('https://www.google.com/jsapi',
                                      '/cached/jsapi')

      recording = ('<script type="text/javascript" language="javascript" '
                   + 'src="recording.js"></script>')
      linestring = linestring.replace('files.js"></script>',
                                      'files.js"></script>\n    ' + recording)


      self.send_response(200)
      self.send_header('Content-type', mimetypes.guess_type(self.path)[0])
      print "Mime type is ", mimetypes.guess_type(self.path)[0]
      if mimetypes.guess_type(self.path)[0] == "audio/mpeg":
        size = os.path.getsize("."+self.path)
        self.send_header('Content-length', str(size) )
        # self.send_header('X-Content-Duration', "20.0" )
        print "FDGC: It was mp3. size=" + str(size)

      self.end_headers()
      self.wfile.write(linestring)
    return

  def do_POST(self):
    print "POST = ", self.path
    m = re.search( r'recording/(.*)', self.path)
    if m:
      filename = m.group(1)
      length = self.headers['content-length']
      data = self.rfile.read(int(length))
      with open('lessons/'+filename, 'w') as fh:
        fh.write(data.decode())
      self.send_response(200)
      self.send_header('Content-type', 'text/txt')
      self.end_headers()
      self.wfile.write("I got a post.")
      print "I wrote the file ", filename
    else:
      self.send_response(403)
      self.send_header('Content-type', 'text/txt')
      self.end_headers()
      self.wfile.write("Not a good path:"+self.path)
    return


class ThreadedHTTPServer(ThreadingMixIn, HTTPServer):
    pass

class ServerThread(threading.Thread):
  def __init__(self):
    super(ServerThread, self).__init__()
    self.port = 8080

  def run(self):
    try:
      #Create a web server and define the handler to manage the
      #incoming request
      # server = HTTPServer(('', self.port), MyHandler)
      server = ThreadedHTTPServer(('', self.port), MyHandler)
      print 'Started httpserver on port ' , self.port
      #Wait forever for incoming htto requests
      server.serve_forever()
    except KeyboardInterrupt:
      print '^C received, shutting down the web server'
      server.socket.close()


call(["mkdir", "-p","cached"])
call(['wget', '-c', "http://ajax.googleapis.com/ajax/libs/jquery/2.0.3/jquery.min.js",
      '-P', 'cached'])
call(['wget', '-c', "http://ajax.googleapis.com/ajax/libs/jquery/2.0.3/jquery.min.map",
      '-P', 'cached'])
call(['wget', '-c', "http://ajax.googleapis.com/ajax/libs/jqueryui/1.10.3/jquery-ui.min.js",
      '-P', 'cached'])
call(['wget', '-c', "https://www.google.com/jsapi",
      '-P', 'cached'])

print "----------------------------------"
print "Starting the server.---"
print "----------------------------------"
t = ServerThread()
t.start()


print "This is the end of the main code of recorder."
