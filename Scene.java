import java.awt.*;

class Scene extends Canvas {
  Dimension d;
  int x[], y[];			// Points.
  int ptc[];			// Point holds color.

  int a[], b[];			// Edges.
  int cx,cy;			// Center of screen.
  int sx,sy;			// Screen scale.
  public float aspect;		// The aspect ration.

  Dimension buf_size;
  Image buf;
  Graphics buf_g;

  Color col[];

  public Scene(int num_pts, int num_edges) {
    //System.out.println("Scene has  " + num_pts+ " points and "+ num_edges + " edges.");
    x = new int[num_pts];
    y = new int[num_pts];
    ptc = new int[num_pts];
    a = new int[num_edges];
    b = new int[num_edges];
    aspect = 1.0f;
    set_size();
    buf = null;
    buf_size = new Dimension(0,0);

    col = new Color[20];
    for(int i=0; i< col.length; i++) {
      col[i] = Color.getHSBColor( .8f * (float)(col.length-i)/col.length, 1,1);
    }
    for(int i=0; i<num_pts; i++) ptc[i] = col.length/2;

  }

  public float max_x() {
    set_size();
    return (float)cx / (float)sx;
  }
  public float max_y() {
    set_size();
    return (float)cy / (float)sy;
  }

  public void set_point(int n, float xp, float yp) {
    x[n] = (int)(  sx*xp + cx);
    y[n] = (int)( -sy*yp + cy);
  }
  // c is from color in nm:  442 nm = Blue, 515 nm = Green, 633 nm = Red. 
  public void set_color(int n, float c, boolean debug) { 
    int i =  (int)(col.length*(c - 442)/(633-442));
    if( debug ) System.out.println(" c="+c+", Using color "+i);
    if( i< 0 ) i = 0;
    if( i > col.length-1) i = col.length-1;
    ptc[n] = i;
  }
  public void set_edge(int n, int an, int bn) {
    //System.out.println("Setting edge " + n+ " to "+ an + "-" + bn);
    a[n] = an;
    b[n] = bn;
  }

  void set_size() {
    d = size();
    cx = d.width /2;
    cy = d.height /2;
    sy = d.height;
    sx = (int) (aspect * sy);
  }
  
  public Dimension preferredSize() {
    return new Dimension(800,400);
  }

  public synchronized Dimension minimumSize() {
    return new Dimension(100,100);
  }
  public void paint(Graphics g) { 
    update(g);
  }
  public void update(Graphics g) { 
    set_size();
    if( (buf == null) || (d.width != buf_size.width)
	|| (d.height != buf_size.height)) {
      buf_size = d;
      buf = createImage(d.width, d.height);
      buf_g = buf.getGraphics();
    };
    buf_g.setColor(getBackground());
    buf_g.fillRect(0, 0, d.width, d.height);
    buf_g.setColor(Color.green);
    buf_g.draw3DRect(0,0, d.width-1, d.height-1, true);
    buf_g.draw3DRect(6,6, d.width-13, d.height-13, false);

    buf_g.setColor(getForeground()); 
    for(int i=0; i< a.length; i++) {
      buf_g.setColor( col[ptc[a[i]]]); 
      buf_g.drawLine(x[a[i]], y[a[i]], x[b[i]], y[b[i]]);
    }

    g.drawImage(buf, 0,0,this);

  }
}
