# Debug Tutorial Feature Test

A test tutorial placed in assets/dev/tutorials to verify debug tutorial
discovery, inline object loading, and interactive tool/canvas directives.

## 1. Setup & Inline Objects

Verify the setup directive resets observer values and loads inline objects
(Alice at x = 0.0 and a moving Train at x = -1.0, v = 0.4). Click Continue.

> reset
> setup: v=0.5, t=0.5, mode=lorentz
> object: person(name="Alice", x=0.0, t=0.0, v=0.0, color=blue)
> object: {"type": "train", "name": "Express", "x": -1.0, "t": 0.0, "v": 0.4, "color": 6}
> ok

## 2. Test Slider Target

Move the velocity slider back to 0.0 so we are in Alice's rest frame.

> v = 0.0

## 3. Add a Light Cone on the Canvas

Switch the tool from Select to Add, choose Light Cone as the object type, and
click the flashing target on the spacetime canvas (at x = 0.0, t = 0.0) to
place a light cone. Notice how the highlighted control updates as you complete
each part!

> add = cone(x=0.0, t=0.0)

## 4. Select an Object

Now switch the tool back to Select and click on Alice's worldline (at x = 0)
in the spacetime diagram to select her.

> select = Alice

## 5. Drag an Object

With Alice selected, drag her worldline to the right to x = 0.5 (or click
"Do it for me").

> move = Alice(x=0.5, tol=0.25)

## 6. Change Object Color

With Alice still selected, use the color palette button in the top toolbar to
change her color to green (color 5).

> color = green

## 7. Switch View Mode to Ether

Open the navigation drawer using the flashing hamburger menu (☰) in the
top-left corner, expand the View section, and select Use Ether.

> mode = ether

## 8. Complete Test

All directive types (multi-directive setup, inline objects, sliders, adding
objects, selecting, dragging, property editing, and view mode switching) are
working!

> ok
