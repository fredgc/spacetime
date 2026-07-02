import java.awt.*;
import java.applet.Applet;


public class Cylinder extends Applet implements Runnable {
  Scene scene;
  ScrollFloat R, velocity, length, omega, Distance, scale, T,dt; // Parameters.
  ScrollFloat aspect;
  float tp, x0, gamma; // Variables.

  final int uN = 8;
  final int thetaN = 16;
  final int num_edge = (uN+1)*(4*thetaN) + uN*thetaN;
  final int num_pts = (uN+1)*(thetaN*4);

  Thread thread;
  Checkbox pause; 
  Checkbox doppler;
  Choice view_map;
  Label gamma_val;

  Button stats;
  boolean debug, debug_set;
  GridBagConstraints c;
  GridBagLayout gridbag;


  public Cylinder() {
    thread = null;
  }
			      
  // Point (i*thetaN*4 +j ) is at u = i/uN*L, theta = 2*pi*j/thetaN*4.
  void init_scene() {
    int n=0;
				// Connect u's: i to i+1.1.
    //System.out.println("Connect the u's.");
    for(int i=0; i< uN; i++) {
      for(int j=0; j < thetaN; j++) {
	//System.out.println("i="+i+", j="+j+", ");
	scene.set_edge(n++, i*thetaN*4 + 4*j, (i+1)*thetaN*4 + 4*j);
      }
    }
    //System.out.println("Connect the theta's.");
    for(int i=0; i< uN+1; i++) {	// Connect theta's:
      int j;
      for(j=0; j < 4*thetaN-1; j++) {
	//System.out.println("i="+i+", j="+j+", ");
	scene.set_edge(n++, i*thetaN*4 + j, i*thetaN*4 + j+1);
      }
      //System.out.println("i="+i+", j="+j+", ");
      scene.set_edge(n++, i*thetaN*4 + j, i*thetaN*4 + 0);
    }
  }
  void find_gamma() {
    float v = velocity.getValue();
    gamma = 1 / (float)(Math.sqrt( 1 - v*v));
    gamma_val.setText("gamma = " + gamma);
  }
  void compute() {
    boolean dop = doppler.getState();

    tp += .1f * dt.getValue();

    float L = length.getValue();
    float v = velocity.getValue();
    float z0 = Distance.getValue();
    float s = scale.getValue();
    float w = omega.getValue();

    x0 -= v*.1f*dt.getValue();
    if( s*(x0 + L)/ ( z0+R.getValue()) < -scene.max_x() ) {
      x0 = (z0+R.getValue())*scene.max_x() / s;
    }
    float x = x0;
    float dx = L/uN / gamma;

    // cu = cos(omega t), su = sin(omega t).  t = tp/gamma + v*u.
    float cu = R.getValue() * (float)Math.cos(w*(tp/gamma - .5*L) );
    float su = R.getValue() * (float)Math.sin(w*(tp/gamma - .5*L) );

    // dcu = change in cos u.   dsu = change in sin u.
    float dcu = (float)Math.cos(w*v * L / uN);
    float dsu = (float)Math.sin(w*v * L / uN);

    // dct = change in cos(theta).
    float dct = (float)Math.cos(2*Math.PI/(thetaN*4));
    float dst = (float)Math.sin(2*Math.PI/(thetaN*4));

    // For doppler effect:
    float temp = w * R.getValue()/gamma;
    float denom = (float)Math.sqrt( 1 - (v*v + temp*temp)); // Approximately 1- vel^2
    
    
    for(int i=0; i< uN+1; i++) {
      x += dx;
      float ct = cu;		// ct = cos(omega t + theta);
      float st = su;
      float mag = (float)Math.sqrt(x*x + z0*z0); // Used for doppler. (approx |p|)
      for(int j=0; j < 4*thetaN; j++) {
	float tempc = ct*dct - st*dst;
	st = ct*dst + st*dct;
	ct = tempc;
	float z = z0 + st;
	scene.set_point(i*thetaN*4+j, s*x/z , s*ct/z);

	if( dop ) {
	  float ur = (-v*x - w*st*ct/gamma + w*ct*z/gamma) / mag; // Radial velocity.
	  float rat = (1+ur) / denom;
	  if( debug ) {
	    System.out.print("Color for pt (" + i + ", "+j+") is ");
	    System.out.print(rat*515 + ", denom = "+denom+", ur = "+ur);
	  }			     
	  scene.set_color( i*thetaN*4+j,  rat*515, debug);
	}
      }
      float tempc = cu * dcu - su * dsu;
      su = cu*dsu + su* dcu;
      cu = tempc;
    }
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
    scene = new Scene(num_pts, num_edge);
    gridbag.setConstraints(scene,c);
    add(scene);
    init_scene();

    c.fill = GridBagConstraints.BOTH;
    c.gridy = GridBagConstraints.RELATIVE;
    c.weighty = 0.1;

    Panel buttons = new Panel();
    buttons.setLayout(new FlowLayout());
    pause = new Checkbox("Pause");
    buttons.add(pause);
    stats = new Button("Debug Info"); 
    buttons.add(stats);
    doppler = new Checkbox("Doppler");
    buttons.add(doppler);
    view_map = new Choice();
    view_map.addItem("World Map");
    view_map.addItem("World View");
    buttons.add(view_map);
    gamma_val = new Label("gamma = *");
    buttons.add(gamma_val);

    gridbag.setConstraints(buttons,c);
    add(buttons);
    
				// Initialize parameters.
    R = addScroll("Radius", 0.25f, 0, 1);
    velocity = addScroll("Velocity", 0.5f, 0, .999f);
    length = addScroll("Length", 1, 0, 3);
    omega = addScroll("Omega", .1f, 0, 1);
    Distance = addScroll("z_0", 3, 3, 20);
    scale = addScroll("scale", 5, 0, 20);
    aspect= addScroll("aspect ratio", scene.aspect, .1f, 3);
    T = addScroll("Max time", 3, 0, 15);
    dt = addScroll("film speed", .1f, 0, 2);

				// Initialize variables.
    tp = 0;
    x0 = 0;
    find_gamma();
    compute();

    validate();

    //System.out.println("Preferred size is " + preferredSize() );
    //System.out.println("size is " + size() );

  }
  
  public void start() {
    if( thread == null ) {
      //System.out.println("starting... ");
      thread = new Thread(this, "Cylinder");
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
    System.out.println("Starting to run.");

    //Just to be nice, lower this thread's priority
    //so it can't interfere with other processing going on.
    Thread.currentThread().setPriority(Thread.MIN_PRIORITY);
    
    //Remember the starting time.
    long time = System.currentTimeMillis();


    float avg = 0;		// Keep some statistics about the delay.
    int n = 0;
    long min = 1000;
    long max = 0;
    
    while( Thread.currentThread() == thread ) {
      if( debug_set ) {
	debug = true;
	debug_set = false;
      }
      try {
	if( ! pause.getState() ) {
	  compute();
	  scene.repaint();
	  time += 100;
	  long delay = Math.max(10, time - System.currentTimeMillis());
	  thread.sleep( delay);
	  if( delay > max ) max = delay;
	  if( delay < min ) min = delay;
	  avg = (n*avg + delay) / (n + 1f);
	  n++;
	  if( debug ) {
	    System.out.println("Average delay = "+avg+", min = "+min+", max = "+max);
	  }
	} else {
	  thread.sleep(100);
	}
      } catch (InterruptedException e){
      }
      if( debug ) debug = false; // Leave debug true for one whole loop.
    }
  }
  public boolean action(Event e, Object arg) {
    if( e.target == stats ) {
      debug_set = true;		// Do to sets of debug prints.
    }
    return false;
  }
  public boolean handleEvent(Event e) {
    if( e.target == velocity ) {
      find_gamma();
    }
    if( e.target == aspect ) {
      scene.aspect = aspect.getValue();
    }
    return super.handleEvent(e);
  }
}

