#!/usr/bin/python

import operator
import os
import re
import subprocess
import sys
import time

global eqn_count
global eqn_base
global page_count
global eqn_cache
global version_number

def handle_equation(match):
  global eqn_count
  global eqn_base
  global eqn_cache
  eqn = match.group(1)
  filename = ""
  if eqn in eqn_cache:
    filename = eqn_cache[eqn]
    print "Reusing ",eqn," as ", filename
  else:
    eqn_count = eqn_count + 1;
    print "eqn count is ", eqn_count
    filename = eqn_base + str(eqn_count) + '.svg'

    with open("/tmp/equation.tex", "w") as fout:
      print "Looking at equation ", eqn
      fout.write("\\documentclass{article}\n")
      fout.write("\\pagestyle{empty}\n")
      fout.write("\\begin{document}\n")
      fout.write(eqn + "\n" )
      fout.write("\\end{document}\n")

    subprocess.call(['/usr/bin/pdflatex', '-halt-on-error',
                     '-output-directory', '/tmp',
                     '/tmp/equation.tex'])
    subprocess.call("pdfcrop /tmp/equation.pdf /tmp/equation_c.pdf", shell=True)
    subprocess.call("pdf2svg /tmp/equation_c.pdf " + filename, shell=True)
    eqn_cache[eqn] = filename

  if match.group(2) == '$$':
    return ('\n<br><center>'
            + '<img src="/' + filename + '" alt="' + match.group(1) + '">'
            + '</center><br>')
  else:
    return '<img src="/' + filename + '" alt="' + match.group(1) + '">'

def handle_page(match):
  global page_count
  page_count = page_count+1
  name = "page" + str(page_count)
  return ('<a name="' + name+ '" id="' + name+ '">\n'
          + '<span id="' + name + '-off" class="page_off">'
          + '<img src="/images/page-open.svg"></span>\n'
          + '<span id="' + name + '-on" class="page_on">'
          + '<img src="/images/page-closed.svg"></span>\n'
          + '<span class="debug">'+name+'</span>'
          + '</a>')

def get_title(filename):
    with open(filename) as fin:
      for line in fin:
        m = re.search("<title>(.*)</title>", line)
        if m:
          return line
    return "NO TITLE"

def copy_body(filename, fout):
    with open(filename) as fin:
      for line in fin:
        line = re.sub("<title>(.*)</title>", "", line)
        line = re.sub("((\${1,2})[^\$]+\${1,2})", handle_equation, line)
        line = re.sub("<a>PAGE</a>", handle_page, line)
        line = re.sub("VERSION", version_number, line)
        fout.write(line)

def do_work(f):
  global eqn_count
  global eqn_base
  global page_count
  global eqn_cache
  eqn_cache = {}
  inpath = "./raw-lessons"
  outpath = "lessons"
  infile = os.path.join(inpath, f)
  outfile = os.path.join(outpath, f)
  eqn_base = re.sub(".html", "-eqn", outfile)
  page_count = 0
  eqn_count = 0
  print "Handleing file ", infile, outfile
  title = get_title(infile)
  print "Title = ", title
  with open(outfile, "w") as fout:
    with open("template.html") as fin:
      for line in fin:
        line = re.sub("TITLE", title, line)
        line = re.sub("VERSION", version_number, line)
        if re.search("BODY", line):
          copy_body(infile, fout)
        else:
          fout.write(line)

  # process = subprocess.call(['diff', infile, outfile])
def find_version():
  global version_number
  with open("./app.yaml") as fin:
    for line in fin:
      m = re.search("version: *(\d*)", line)
      if m:
        version_number = ("v" + m.group(1) + " " +
                          time.strftime("(%d %b %Y)"))
        return
  version_number = "-unkown-version-"

find_version()

if len(sys.argv) > 1:
  for f in sys.argv[1:]:
    do_work(f + ".html")
else:
  for f in os.listdir("./raw-lessons"):
    do_work(f)


print "Done with parse_files.py."
