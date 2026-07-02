/** $Id: ScrollFloat.java,v 1.2 1998/03/18 05:42:21 fredgc Exp fredgc $
  ScrollFloat is a scroll bar with a text field for editing floating
  point numbers. 

  Written by:
   Fred Gylys-Colwell
   fredgc@gchouse.org

   while at:
   Ball State University, Dept. of Math. Sci.
   Muncie, IN, 47306

 */

import java.awt.*;

public class ScrollFloat extends Panel {
  float x;
  float min,max;

  Scrollbar bar;
  Label l;
  TextField value;
  
  public ScrollFloat(String name, float val,
		      float min_new, float max_new) {
    super();

    //System.out.println("Creating new scroll bar " + name );

    max = max_new;
    min = min_new;
    x = val;

    GridBagConstraints c = new GridBagConstraints();
    GridBagLayout gridbag = new GridBagLayout();
    setLayout(gridbag);
    c.fill = GridBagConstraints.BOTH;
    c.weightx = 0.01;
    c.gridx = GridBagConstraints.RELATIVE;

    l = new Label(name + ":");
    gridbag.setConstraints(l,c);
    add(l);

    value = new TextField(10);
    gridbag.setConstraints(value,c);
    add(value);

    bar = new Scrollbar(Scrollbar.HORIZONTAL, 500, 100, 0, 1100);
    c.fill = GridBagConstraints.HORIZONTAL;
    c.weightx = 1.0;
    gridbag.setConstraints(bar,c);
    add(bar);

    setValue(val);

    bar.setLineIncrement(10);	// One click changes by 1 percent.
  }

  public void setValue(float v) {
    //System.out.println(l.getText() + " set value = "+v + "  ");
    if( v < min ) v = min;
    if( v > max ) v = max;
    x = v;
    value.setText(" "+x);
    bar.setValue( (int)Math.round( 1000 * (x-min)/(max-min)));
  }

  public float getValue() {
    return x;
  }
    
  public boolean action(Event e, Object arg) {
    //System.out.print("Action in " + l.getText());
    if( e.target == value ) {
      e.target = this;
      setValue( Float.valueOf(value.getText()).floatValue() );
      return false;
    };
    //System.out.println("******* Action on " + e.target);
    return super.action(e,arg);
  }

  public boolean handleEvent(Event e) {	
    if( e.target == bar ) {
      switch (e.id) {
      case Event.SCROLL_LINE_UP:
      case Event.SCROLL_LINE_DOWN:
      case Event.SCROLL_PAGE_UP:
      case Event.SCROLL_PAGE_DOWN:
      case Event.SCROLL_ABSOLUTE:
	setValue( 0.001f*(max-min)*bar.getValue() + min);
	super.handleEvent(e);
	e.target = this;
	return false;
      }
    }
    return super.handleEvent(e);
  }

}
