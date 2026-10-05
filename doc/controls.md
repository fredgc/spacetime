---
title: Toolbar and Sliders
---

The top and bottom bars of the application contain controls to manipulate and
explore the spacetime diagram:

## Menu

### Settings

Clicking on the gear icon will open the settings page. Settings are saved
locally. Colors are tied to settings -- not to the drawing.

### File

Save or load files. See [File Management](files.html) for help.

### Edit Menu

Cut and Paste.

### View

Choose Lorentz, Ether, or Emitter for the light speed transformation.
See [Relativistic Transformations](transformations.html) for more information.


## Editor Tools (Top Bar)

* **Add/Select**: Tap this button to change whether you are adding or selecting
  an object.

  * **Select**: Allows selecting objects in the Spacetime Diagram or
    Side View to view details, edit names, or change colors.

  * **Add**: Add an object to the scene. Click in the main view or the side view
    to add an object.

* **Name**: The color of the selected object, or the color of the object that
  will be added. Tap on the text to change the name.

* **Type**: The type of the selected object, or the type of object that will be
  added.

  * **Event**. A single point in time and space.

  * **Instant**. An instant in time, relative to the the current observer. This
    is a horizontal line when you are not using the Lorentz transformation.

  * **Light Cone**. A pair of light rays moving left and right. The speed of
    light is $c = 1.0$.

  * **Location (Clock/Person/Train/Barn/Flag)**: A single location, relative to
    the current observer.

* **Color**: The color of the selected object, or the color of the object that
  will be added.

## Sliders (Bottom Bar)

* **Time ($t$) Slider**: Moves the current observer time forward and backward.
  Adjusting this slider animates the position of locations and the state of
  events/clocks in the Side View. Press the arrow to the right of the slider to
  start animating time forward. The arrow on the left animates time backwards.

* **Velocity ($v$) Slider**: Changes the relative velocity of the observer
  frame. Modifying the velocity instantly recalculates and transforms the
  positions of all objects on both diagrams according to the selected
  transformation model.
