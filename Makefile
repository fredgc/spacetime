run:
	./parse_files.py
	./test_server.py

appengine: spacetime.tgz
	./parse_files.py
	dev_appserver.py --port=8083 .

install: spacetime.tgz
	./parse_files.py
	appcfg.py update -e fredgc@gchouse.org .

lessons/%.html: raw-lessons/%.html parse_files.py template.html
	./parse_files.py $*

FILES := $(wildcard *.js) $(wildcard *.py) $(wildcard *.html) stylesheets \
         Makefile app.yaml
spacetime.tgz: $(FILES)
	cd ..; tar  --transform "s/relativity/spacetime/" -czf relativity/spacetime.tgz $(addprefix relativity/,$(FILES))
