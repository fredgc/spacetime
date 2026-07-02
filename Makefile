# This draws some pictures illustrating relativity.

.SUFFIXES: .java .class
.java.class:
	javac -classpath $(HOME)/lib/classes.jar:. $*.java
JAVA = java -classpath $(HOME)/lib/classes.jar:.

SOURCE = Drawing.java ScrollFloat.java PaneLayout.java Cylinder.java \
	Scene.java Sample1.java Sample2.java

# Draw events etc. with lorentz transform.
test-d: ScrollFloat.class Drawing.class PaneLayout.class
	$(JAVA) net.sourceforge.jmisc.RunApplet Drawing
test-d2: ScrollFloat.class Drawing.class PaneLayout.class
	java -classpath . Drawing

# Draw a rotating cylinder under a lorentz transformation.
test-c: ScrollFloat.class Cylinder.class Scene.class
	$(JAVA) net.sourceforge.jmisc.RunApplet Cylinder
cylinder.prof: ScrollFloat.class Cylinder.class Scene.class sortprof
	$(JAVA) -prof net.sourceforge.jmisc.RunApplet Cylinder
	sortprof < java.prof > cylinder.prof

# Draw colors from red to blue.
test2: Sample2.class
	$(JAVA) net.sourceforge.jmisc.RunApplet Sample2

# Draw a rotating cylinder under a lorentz transformation.
test1: ScrollFloat.class Sample1.class
	$(JAVA) net.sourceforge.jmisc.RunApplet Sample1

rcs: $(SOURCE)
	ci -l Makefile $(SOURCE)

install: ScrollFloat.class Drawing.class Cylinder.class Scene.class \
	PaneLayout.class Drawing.java PaneLayout.java ScrollFloat.java code.jar
	cp *.class Drawing.java PaneLayout.java ScrollFloat.java code.jar ~/public_html/published/relativity/ 

code.jar: ScrollFloat.java Drawing.java Cylinder.java Scene.java \
	PaneLayout.java
	rm -f *.class
	javac $^
	jar cf code.jar *.class

floppy: index.htm space.htm cyl.htm code.jar install.bat 
	mount /floppy
	cp index.htm space.htm cyl.htm code.jar install.bat /floppy
	cp Cylinder.class /floppy/zz1.cls
	cp MyCanvas.class /floppy/zz2.cls
	cp Sample2.class /floppy/zz3.cls
	cp DrawCone.class /floppy/zz4.cls
	cp PaneComponent.class /floppy/zz5.cls
	cp Scene.class /floppy/zz6.cls
	cp DrawLine.class /floppy/zz7.cls
	cp PaneLayout.class /floppy/zz8.cls
	cp ScrollAction.class /floppy/zz9.cls
	cp DrawThing.class /floppy/zz10.cls
	cp PaneRow.class /floppy/zz11.cls
	cp ScrollFloat.class /floppy/zz12.cls
	cp Drawing.class /floppy/zz13.cls
	cp Sample1.class /floppy/zz14.cls
	umount /floppy

clean:
	rm -f *.class sortprof *~ *.prof

