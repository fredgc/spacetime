/* Sample2: play with colors for a red/blue shift. */

/* light frequencies:  442 nm = Blue, 515 nm = Green, 633 nm = Red. */
/* Radius of earth = 6380 km.  Mass = 5.98e27 gramms. */
/* Speed of light: 3e8 m/sec.  WANGO!! LOOK THIS UP!! */


import java.awt.*;
import java.applet.Applet;

public class Sample2 extends Applet {
  Color lin[], arc[];
  final int n = 10;
  
  public void init() {		// This is run when an applet is loaded.
    setBackground(Color.black); // Use non-reverse vidio.
    setForeground(Color.white);

    lin = new Color[2*n];
    for(int i=0; i<n; i++) {
      lin[i] = new Color( 0,i*255/n, (n-i)*255/n);
      lin[i+n] = new Color( i*255/n, (n-i)*255/n,0);
    };
    arc = new Color[2*n];
    for(int i=0; i<2*n; i++) {
      arc[i] = Color.getHSBColor( .4f * (float)(2*n-i)/n, 1, 1);
    };

  };
    
  public void start() {
  }
  public void stop() {
  }
    
  public void destroy() {	// This is run when the object is destroyed.
    System.out.println("Destroy!");
  }
    
  public void paint(Graphics g) {
    int w = size().width;
    int h = size().height;

    g.setColor(Color.black);
    g.fillRect(0, 0, w, h);
    w = (w-10) / (2*n);
    h = h/2;
    for( int i = 0; i < 2*n; i++) {
      g.setColor(lin[i]);
      g.fillRect(5 + i*w+2, 2, w-4, h-4);
      g.setColor(arc[i]);
      g.fillRect(5 + i*w+2, h+2, w-4, h-4);
    }
  }
  public Dimension minimumSize() {
    return new Dimension(400,400);
  }
  public Dimension preferredSize() {
    return minimumSize();
  }
}

