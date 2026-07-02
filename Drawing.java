/**
   $Id: Drawing.java,v 1.2 1998/03/18 05:42:21 fredgc Exp fredgc $
   Drawing.java is a simple drawing program with the Lorentz 
   transformation built in.

   Written by:
   Fred Gylys-Colwell
   fredgc@gchouse.org

   while at:
   Ball State University, Dept. of Math. Sci.
   Muncie, IN, 47306

*/

import java.awt.*;
import java.applet.Applet;
import java.awt.event.*;
import java.util.*;

/** MyCanvas is the actual image. */
class MyCanvas extends Canvas {
    Drawing parent;		// The parent container.
    DrawThing list;		// A list of things to draw.
    Color background;
    Color foreground;

    MyCanvas(Drawing d ) {	// A Constructor.
	parent = d;
	background = Color.white;
	foreground = Color.black;
    }

    public Dimension preferredSize() {
	return new Dimension(400,300);
    }

    public synchronized Dimension minimumSize() {
	return new Dimension(100,100);
    }

    Dimension d;			// The current size of the canvas.
    /* The following variables are used to convert from world to screen
       cooridnates.  See findX etc. */
    double mx, my;		
    double sxx, sxt, syx, syt;
    int bx, by;

    synchronized void newTrans() {
	d = null;
	repaint();
    }
    synchronized void translate(Dimension newd) {
	d = newd;
	bx = d.width/2;		// t', x' to screen. 
	by = d.height/2;
	mx = d.width/2.0;
	my = -d.height/2.0;

	sxx = parent.gamma * mx;	// t,x to screen.
	sxt = -parent.gamma * mx * parent.v;
	syx = -parent.gamma * my * parent.v;
	syt = parent.gamma * my;
    }

    /** Convert world x' (current refrence frame) to screen x. */
    int findXP(double x) {
	return (int)Math.round(x*mx + bx);
    }

    /** Convert world t' (current refrence frame) to screen y. */
    int findYP(double t) {
	return (int)Math.round(t*my + by);
    }

    /** Convert world (x,t) (0 velocity refrence frame) to screen x. */
    int findX(double x, double t) {
	return (int)Math.round(x*sxx+t*sxt + bx);
    }

    /** Convert world (x,t) (0 velocity refrence frame) to screen y. */
    int findY(double x, double t) {
	return (int)Math.round(x*syx+t*syt + by);
    }

    /** paint is called when the canvas is drawn the first time. */
    public void paint(Graphics g) {
	translate(size());
	g.setColor(background);
	g.fillRect(0,0, d.width, d.height);
	g.setColor(foreground);
	g.drawRect(0,0, d.width-1, d.height-1);
	update(g);
    }
      
    /** update is called when the canvas is redrawn. */
    public void update(Graphics g) {
	Dimension newd = size();
	if( (d == null) ||
	    (d.width != newd.width) || (d.height != newd.height) ) {
	    translate(newd);
	    paint(g);
	    return;
	}

	g.clipRect(1,1, d.width-2, d.height-2);

	g.setColor(background);	// Erase old lines by drawing in black.
	for( DrawThing d = list; d != null; d = d.next) {
	    d.paint(g);
	}
	// Draw the grid lines.
	if( background == Color.white ) {
	    g.setColor(Color.darkGray);
	} else {
	    g.setColor(Color.gray);
	}
	for(double t= -1.0; t< 1.1; t+= .1) {
	    int y = findYP(t);
	    g.drawLine(0,y, d.width, y);
	}
	for(double x= -1.0; x< 1.1; x+= .1) {
	    int sx = findXP(x);
	    g.drawLine(sx,0,sx, d.height);
	}
	// Draw new lines.
	list = parent.list;
	for( DrawThing d = list; d != null; d = d.next) {
	    g.setColor(d.c);
	    d.translate(this);
	    d.paint(g);
	}
    }

    /** Handle a mouse click event. */
    public boolean mouseDown(Event e, int x, int y) {
	double xp = (x-bx)/mx;
	double tp = (y-by)/my;
	parent.addThing( xp, tp);
	return super.mouseDown(e, x, y);
    }

}

/** A DrawThing is either a line, an event or a light cone.
    It defaults to being an event.
*/
class DrawThing {		
    DrawThing next=null;
    Color c;
    double t,x;

    int sx, sy;

    DrawThing(DrawThing next, Color c, double x, double t) {
	this.next = next;
	this.c = c;
	this.x = x;
	this.t = t;
    }

    void translate(MyCanvas canvas) {
	sx = canvas.findX(x,t);
	sy = canvas.findY(x,t);
    }
    void paint(Graphics g) {
	g.fillOval(sx-2,sy-2, 5,5);
    }
      
}

/** A Light cone: */
class DrawCone extends DrawThing {
    DrawCone(DrawThing next, Color c, double x, double t) {
	super(next,c,x,t);
    }
    int sx1,sx2, sy1,sy2;
    int sx3,sx4, sy3,sy4;
    void translate(MyCanvas canvas) {
	sx1 = canvas.findX(x-2,t-2);
	sy1 = canvas.findY(x-2,t-2);
	sx2 = canvas.findX(x+2,t+2);
	sy2 = canvas.findY(x+2,t+2);
	sx3 = canvas.findX(x-2,t+2);
	sy3 = canvas.findY(x-2,t+2);
	sx4 = canvas.findX(x+2,t-2);
	sy4 = canvas.findY(x+2,t-2);
    }
    void paint(Graphics g) {
	g.drawLine(sx1,sy1, sx2,sy2);
	g.drawLine(sx3,sy3, sx4,sy4);
    }
}

/** An instant or place is just a line: */
class DrawLine extends DrawThing {
    double x1,t1,x2,t2;
    int sx1, sx2, sy1, sy2;
    DrawLine(DrawThing next, Color c, double x1, double t1,
	     double x2, double t2) {
	super(next,c,x1,t1);
	this.x1 = x1;
	this.x2 = x2;
	this.t1 = t1;
	this.t2 = t2;
    }
    void translate(MyCanvas canvas) {
	sx1 = canvas.findX(x1,t1);
	sy1 = canvas.findY(x1,t1);
	sx2 = canvas.findX(x2,t2);
	sy2 = canvas.findY(x2,t2);
    }
    void paint(Graphics g) {
	g.drawLine(sx1,sy1, sx2,sy2);
    }
}

/** This is the main class which has the canvas and all the buttons. */
public class Drawing extends Applet  {
    ScrollFloat velocity;
    float v = 0;
    MyCanvas canvas;
    CheckboxGroup drawGroup;
    Checkbox event, cone, instant, place;
    Button undo, clear;
    float gamma = 1;
    Label gammaLabel;
    Checkbox reverse;

    static final Color colorList[] = { Color.blue, Color.green,
				       Color.yellow, Color.magenta, Color.cyan,
				       Color.orange, Color.pink, Color.red,
				       Color.black, Color.white};
    static final String colorNames[] = { "blue", "green",
					 "yellow", "magenta", "cyan",
					 "orange", "pink", "red",
					 "black", "white"};
    Choice colorChoice;
  
    DrawThing list = null;
  
    /** init() is called when the applet first starts. */
    public void init() {
	PaneLayout p = new PaneLayout();
	setLayout(p);

	canvas = new MyCanvas(this);
	p.newLine(true);
	add("fill", canvas);
	p.newLine();

	velocity = new ScrollFloat("velocity", v, -.99f, .99f);
	add("fill",velocity);
	p.newLine();
	add(" ", new Label("Add: "));
	drawGroup = new CheckboxGroup();
	event = new Checkbox("Event", drawGroup, true);
	add(" ", event);
	cone = new Checkbox("Light Cone", drawGroup, false);
	add(" ", cone);
	instant = new Checkbox("Instant", drawGroup, false);
	add(" ", instant);
	place = new Checkbox("Place", drawGroup, false);
	add(" ", place);
	p.newLine();
	undo = new Button("Undo");
	add(" ", undo);
	clear = new Button("Clear");
	add(" ", clear);
	colorChoice = new Choice();
	for(int i=0; i< colorList.length; i++) {
	    colorChoice.addItem(colorNames[i]);
	};
	colorChoice.select(0);
	add(" ", colorChoice);
	gammaLabel = new Label("gamma = "+gamma);
	add("fill", gammaLabel);
	reverse = new Checkbox("Light Background", null, true);
	add(" ", reverse);
    
	validate();
    }

    /** Compute the time dilation from the new velocity. */
    void findGamma() {
	float newv = velocity.getValue();
	if( Math.abs(newv - v) < 0.0001 ) return; 
	v = newv;
	gamma = (float)Math.sqrt( 1.0/(1-v*v));
	gammaLabel.setText("gamma = "+gamma);
	canvas.newTrans();
    }

    /** Add a new event, light cone, or line. */
    void addThing(double xp, double tp) {
	//System.out.println("Add thing at "+xp+", "+tp);
	int n = colorChoice.getSelectedIndex();
	if( drawGroup.getCurrent() == cone) {
	    double x = gamma*(xp + v*tp);
	    double t = gamma*(tp + v*xp);
	    list = new DrawCone(list, colorList[n], x, t);
	} else if( drawGroup.getCurrent() == instant) {
	    double x0 = gamma*(-2 + v*tp);
	    double t0 = gamma*(tp + v*(-2));
	    double x1 = gamma*(2 + v*tp);
	    double t1 = gamma*(tp + v*2);
	    list = new DrawLine(list, colorList[n], x0,t0,x1,t1);
	} else if( drawGroup.getCurrent() == place) {
	    double x0 = gamma*(xp -2*v);
	    double t0 = gamma*(-2 + v*xp);
	    double x1 = gamma*(xp + v*2);
	    double t1 = gamma*(2 + v*xp);
	    list = new DrawLine(list, colorList[n], x0,t0,x1,t1);
	} else {
	    double x = gamma*(xp + v*tp);
	    double t = gamma*(tp + v*xp);
	    list = new DrawThing(list, colorList[n], x, t);
	}
	canvas.repaint();		// Tell the canvas to redraw itself. 
    }

    /** Remove the most recent item on the list. */
    void undo() {
	if( list != null ) list = list.next;
	canvas.repaint();
    }

    /** Handle an event from the operating system. */
    public boolean action(Event e, Object arg) {
	if( e.target == undo ) {
	    undo();
	    return true;
	}
	if( e.target == clear ) {
	    list = null;
	    canvas.repaint();
	    return true;
	}
	if( e.target == reverse ) {
	    if( reverse.getState() ) {
		canvas.background = Color.white;
		canvas.foreground = Color.black;
	    } else {
		canvas.background = Color.black;
		canvas.foreground = Color.white;
	    }
	    canvas.d = null;	// force a repaint.
	    canvas.repaint();
	    return true;
	}
	return super.action(e,arg);
    }

    /** Handle a keyboard event from the operating system.
	This should allow keyboard shortcuts, but it doesn't seem to
	work very well. */  
    public boolean keyDown(Event e, int key) {
	switch(key) {
	  case 'e':
	    drawGroup.setCurrent(event);
	    break;
	  case 'c':
	    drawGroup.setCurrent(cone);
	    break;
	  case 'i':
	    drawGroup.setCurrent(instant);
	    break;
	  case 'p':
	    drawGroup.setCurrent(place);
	    break;
	  case 'z':
	    undo();
	    break;
	}
	return super.keyDown(e, key);
    }
    
    public boolean handleEvent(Event e) {
	if( e.target == velocity ) {
	    findGamma();
	}
	return super.handleEvent(e);
    }
  
    /** This is used by some browsers to figure out what this applet does. */
    public String getAppletInfo() {
	return "Drawing applet by Fred Gylys-Colwell";
    }

    public static void main(String [] args) {
	//Create a new window.
	Frame f = new Frame("Spacetime Drawing Applet");
    
	//Create a Drawing instance.
	Drawing d = new Drawing();
    
	//Initialize the Converter instance.
	d.init();
    
	//Add the Converter to the window and display the window.
	f.add("Center", d);
	f.pack();        //Resizes the window to its natural size.
	f.show();
	f.addWindowListener(new WindowAdapter() {
		public void windowClosing(WindowEvent e) {
		    System.exit(0);
		}
	    });
    }

}

