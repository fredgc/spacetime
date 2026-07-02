// $Id: PaneLayout.java,v 1.1 1998/03/18 05:40:42 fredgc Exp $
/** PaneLayout is a special layout for the ode program, editor class.
   It lays things out in rows (like TeX).  Rows can also be temporarily 
   hidden.

  Written by:
   Fred Gylys-Colwell
   fredgc@gchouse.org

   while at:
   Ball State University, Dept. of Math. Sci.
   Muncie, IN, 47306

  */


import java.awt.*;

import java.util.Hashtable;
import java.util.Enumeration;
import java.util.Vector;
/** A PaneComponent keeps track of one component in a row. */
final class PaneComponent {		// One component in a row.
  Component c;
  Dimension d;
  boolean fill;

  PaneComponent(Component c, boolean fill) {
    this.c = c;
    this.fill = fill;
  }

  /** size(true) computes the prefered size. size(false) computes the
    minimum size.
    */
  void size(boolean prefer) {
    if( prefer ) {
      d = c.preferredSize();
    } else {
      d =  c.minimumSize();
    }
  }

  final void reshape(int x,int y,int width, int height) {
    c.reshape(x,y,width,height);
  }
}

/** A PaneRow has a list of PaneComponents. */
final class PaneRow {			// One row.
  Vector cs;			// The components in this row. 
  Dimension d;
  int hgap;
  int fills;			// The number of components with fill=true.
  String name;			// Used to toggle visible/invisible.
  boolean visible;		// If this row is visible.
  boolean fill;			// If this row should fill vertically.
  
  PaneRow(String name, int gap, boolean f) {
    cs = new Vector();
    d = new Dimension(0,0);
    hgap = gap;
    fill = f;
    fills = 0;
    this.name = name;
    visible = true;
  }

  void add(Component c, boolean fill) {
    if( fill) fills++;
    cs.addElement( new PaneComponent(c,fill));
  }

  boolean remove(Component c) {
    for(int i=0; i< cs.size(); i++) {
      PaneComponent pc = (PaneComponent) cs.elementAt(i);
      if( c == pc.c ) {
	if( pc.fill) fills--;
	pc.c = null;
	cs.removeElementAt(i);
	return ( cs.size() == 0 );
      }
    }
    return false;
  }

  void hide() {
    visible = false;
    for(int i=0; i< cs.size(); i++) {
      PaneComponent pc = (PaneComponent) cs.elementAt(i);
      pc.c.hide();
    }
  }

  void show() {
    visible = true;
    for(int i=0; i< cs.size(); i++) {
      PaneComponent pc = (PaneComponent) cs.elementAt(i);
      pc.c.show();
    }
  }

  /** size(true) computes the prefered size. size(false) computes the
    minimum size.
    */
  void size(boolean prefer) {
    d.width = 0;
    d.height = 0;
    for(int i=0; i< cs.size(); i++) {
      PaneComponent c = (PaneComponent)cs.elementAt(i);
      c.size(prefer);
      d.width += c.d.width + hgap;
      d.height = Math.max(c.d.height, d.height);      
    }
    d.width -= hgap;
  }

  final void reshape(int x, int y, int width, int height) {
    size(true);
    if( d.width > width ) size(false);
    int extra = width - d.width;
    if( fills > 0 ) extra = extra/fills;
    for( int i=0; i< cs.size(); i++) {
      PaneComponent c = (PaneComponent)cs.elementAt(i);
      if( c.fill ) c.d.width += extra;
      if( fill) c.d.height = height;
      c.reshape(x,y, c.d.width, c.d.height);
      x += c.d.width + hgap;
    }
  }
}

final public class PaneLayout implements LayoutManager {
  
  private int vgap, hgap;
  Vector rows;
  int fills=0;			// The number of rows with fill=true.
  String last_name;
  static final boolean debug=false;

  public PaneLayout() {
    this("all");
  }

  /** The first row has name "name" */
  public PaneLayout(String name) { 
    this(2,2, name);
  }

  /** The first row has name "name".  Use v and h as inter-row gaps. */
  public PaneLayout(int v, int h, String name) {
    vgap = v;
    hgap = h;
    rows = new Vector();
    last_name = name;
  }

  /** Start a new row.  If f is true, then it should fill vertically. */
  public void newLine(boolean f) {	
    newLine(last_name,f);
  }

  /** Start a new row. */
  public void newLine() {
    newLine(last_name,false);
  }

  /** Start a new row with a new name. */
  public void newLine(String name) { 
    newLine(name, false);
  }

  /** Start a new row with a new name, if f=true, it should fill. */
  public void newLine(String name,boolean f) {
    if(debug) System.out.println("PaneLayout: adding line #"+
				 rows.size()+", "+name);
    rows.addElement( new PaneRow(name, hgap, f));
    last_name = name;
  }

  /** Hide all rows with this name. */
  public void hideLine(String name) { 
    if(debug) System.out.println("PaneLayout: hiding line "+name);
    for(int i=0; i<rows.size(); i++ ) {
      PaneRow r = (PaneRow) rows.elementAt(i);
      if( name.equals(r.name) ) {
	if(debug) System.out.println(" -- line "+i);
	r.hide();
      }
    }
  }

  /** Show all rows with this name. */
  public void showLine(String name) { 
    if(debug) System.out.println("PaneLayout: showing line "+name);
    for(int i=0; i<rows.size(); i++ ) {
      PaneRow r = (PaneRow) rows.elementAt(i);
      if( name.equals(r.name) ) {
	if(debug) System.out.println(" -- line "+i);
	r.show();
      }
    }
  }

  public void addLayoutComponent(String name, Component comp) {
    if(debug) System.out.println("PaneLayout: adding "+name + ", "+comp);
    boolean fill = name.equals("fill");
    if( rows.size() == 0 ) newLine();
    PaneRow r = (PaneRow) rows.lastElement();
    r.add(comp, fill);
  }

  public void removeLayoutComponent(Component comp) {
    if(debug) System.out.println("PaneLayout: removing "+comp);
    for(int i=0; i< rows.size(); i++) {
      PaneRow r = (PaneRow) rows.elementAt(i);
      if( r.remove(comp) ) rows.removeElementAt(i);
      if(debug) System.out.println(" -- was in row "+i);
    }
  }
  
  public Dimension minimumLayoutSize(Container parent) {
    return layoutSize(parent, false);
  }
  public Dimension preferredLayoutSize(Container parent) {
    return layoutSize(parent, true);
  }
  
  /** If prefer=true, compute prefered size, otherwise compute minimum
    size. */
  Dimension layoutSize(Container parent, boolean prefer) {
    Dimension dim = new Dimension(0,0);
    fills = 0;
    if(debug) System.out.println("PaneLayout: finding layout #r="+rows.size());
    for(int i=0; i< rows.size(); i++) {
      PaneRow r = (PaneRow) rows.elementAt(i);
      if( r.visible) {
	r.size(prefer);
	if(debug) System.out.println(" r("+i+") has size "+r.d);
	if(debug) System.out.println(" r("+i+") has "+r.cs.size()+" elements");
	dim.width = Math.max(dim.width, r.d.width);
	dim.height += r.d.height + vgap;
	if( r.fill) fills++;
      }
    }
    dim.height -= vgap;
    //Always add the container's insets!
    Insets insets = parent.insets();
    dim.width  += insets.left+insets.right;
    dim.height += insets.top+insets.bottom;
    if(debug) System.out.println(" total size = "+dim);
    return dim;
  }

  public void layoutContainer(Container parent) {
    Insets insets = parent.insets();
    Dimension dim = parent.size();
    boolean prefer = true;
    int width = dim.width - insets.right - insets.left;
    if(debug) System.out.print("PaneLayout: layout #r="+rows.size());
    if(debug) System.out.println(" size = "+dim);

    Dimension prefered = layoutSize(parent, true);
    if( prefered.height > dim.height ) {
      prefer = false;
      prefered = layoutSize(parent, false);
    }

    int extra = dim.height - prefered.height;
    if( fills > 0 ) extra = extra/fills;
    if( debug ) System.out.println("fills = "+fills+", extra = "+extra);
    
    int y = insets.top;
    for(int i=0; i< rows.size(); i++) {
      PaneRow r = (PaneRow) rows.elementAt(i);
      if( r.visible) {
	int h = r.d.height;
	if( r.fill) h += extra;
	if(debug) System.out.println("Reshape row "+i+" to "+width+" by "+
				     h); 
	r.reshape(insets.right, y, width, h);
	if(debug) System.out.println("Reshaped row "+i+" to "+width+" by "+
				     r.d.height); 
	y += vgap + h;
      }
    }
  }
  
  public String toString() {
    return getClass().getName() + "[vgap=" + vgap + ", hgap="+hgap+ "]";
  }
}


