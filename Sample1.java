import java.awt.*;
import java.applet.Applet;
import net.sourceforge.jmisc.*;

public class Sample1 extends Applet implements Runnable {
  ScrollFloat R, velocity, length, omega, Distance, scale, T,dt; // Parameters.

  Thread thread;
  boolean paused;
  Button pause, stats;

  float avg;		// Keep some statistics about the delay.
  long min;
  long max;

  GridBagConstraints c;
  GridBagLayout gridbag;


  public Sample1() {
    thread = null;
    paused = false;
  }

  ScrollFloat addScroll(String name, float val, float min, float max) {
    ScrollFloat temp = new ScrollFloat(name, val, min,max);
    gridbag.setConstraints(temp,c);
    add(temp);
    return temp;
  }
    

  public void init() {		// This is run when an applet is loaded.
    //System.out.println("Init()");
    setBackground(Color.black); // Use non-reverse vidio.
    setForeground(Color.white);

    c = new GridBagConstraints();
    gridbag = new GridBagLayout();
    setLayout(gridbag);

    c.fill = GridBagConstraints.BOTH;
    c.gridy = 0;
    c.gridx = 0;
    c.weighty = 1.0;

    c.fill = GridBagConstraints.BOTH;
    c.gridy = GridBagConstraints.RELATIVE;
    c.weighty = 0.1;
    
				// Initialize parameters.
    R = addScroll("Radius", 0.25f, 0, 3);
    velocity = addScroll("Velocity", 0.5f, 0, .99f);
    length = addScroll("Length", 1, 0, 3);
    omega = addScroll("Omega", .1f, 0, 1);
    Distance = addScroll("z_0", 3, 0, 3);
    scale = addScroll("scale", 5, 0, 10);
    T = addScroll("Max time", 3, 0, 10);
    dt = addScroll("time step", .1f, 0, .5f);

    validate();

    //System.out.println("Preferred size is " + preferredSize() );
    //System.out.println("size is " + size() );

  }
  
  public void start() {
    if( thread == null ) {
      //System.out.println("starting... ");
      thread = new Thread(this, "Sample1");
      thread.start();
    } else System.out.println("Tried to restart.");

  }
  
  public void stop() {
    //System.out.println("stopping... ");
    thread = null;
  }
  
  public void destroy() {
    //System.out.println("preparing for unloading...");
  }

  public void run() {
    //Just to be nice, lower this thread's priority
    //so it can't interfere with other processing going on.
    Thread.currentThread().setPriority(Thread.MIN_PRIORITY);
    
    //Remember the starting time.
    long time = System.currentTimeMillis();


    
    while( Thread.currentThread() == thread ) {
      try {
	thread.sleep( 1000);
      } catch (InterruptedException e){
      }
    }
  }
  
  public boolean handleEvent(Event e) {
    if( (e.id != Event.MOUSE_ENTER) && (e.id != Event.MOUSE_EXIT) &&
	(e.id != Event.MOUSE_MOVE)) {
      // System.out.println("Sample1 Event = " + e);
      if( e.target == Distance ) {
	System.out.println("Distance = " + Distance.getValue());
      }
      
    }
    return super.handleEvent(e);
  }
}

