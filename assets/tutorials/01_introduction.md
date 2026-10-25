# 1. Introduction: Using the Spacetime Tool

Learn how to draw Minkowski spacetime diagrams, edit objects, and explore
frames of reference.

## 1. What's in the Display

Welcome to the Relativistic Spacetime Drawing Tool! The screen is split into
two views:

* **Spacetime Diagram (top)**: Space ($x$) is on the horizontal axis and time
  ($t$) is on the vertical axis, in units where the speed of light is $c = 1$.

* **Observer View (bottom)**: Shows a 1D animation slice of what the observer
  sees at the current instant of time $t$ (marked by the horizontal bar in the
  spacetime diagram).

Click **Continue** to start placing objects on the diagram.

> reset
> setup: v=0.0, t=0.0, mode=lorentz
> ok

## 2. Adding an Event

The toolbar above the diagram lets you switch between **Select** and **Add**,
and choose what kind of object to create.

Switch the tool to **Add**, choose **Event**, and click the flashing target on
the spacetime canvas at $(x = 0.0, t = 0.5)$ (or click **Do it for me**).

> add = event(x=0.0, t=0.5)

## 3. Worldlines, Light Cones & Instants

In addition to single events, you can draw:

* **Locations (Person, Train, Barn, Flag, Clock)**: Lines representing objects
  moving through time (worldlines).

* **Light Cone**: Two rays of light expanding left and right with slope $\pm 1$
  (since $c = 1$).

* **Instant**: A line of all events that happen at the same time for an
  observer.

With **Add** active, choose **Light Cone** and click the origin
$(x = 0.0, t = 0.0)$ to add a flash of light.

> add = cone(x=0.0, t=0.0)

## 4. Selecting Objects

To inspect or modify an existing object, switch the tool to **Select** and
click on the object in the diagram. (If you click and drag empty space, you pan
the viewport.)

We have added a person named **Alice** at $x = -0.5$. Switch to **Select** and
click on Alice's worldline to select her.

> object: person(name="Alice", x=-0.5, t=0.0, v=0.0, color=blue)
> select = Alice

## 5. Moving & Editing Objects

When an object is selected, you can change its name or color in the top
toolbar, delete it, or drag it to a new position on the canvas.

Drag **Alice** to the right to $x = 0.5$ (or click **Do it for me**).

> move = Alice(x=0.5, tol=0.25)

## 6. Animating Time

Below the Observer View is the **Time** slider, which moves the current time
slice $t$ up and down the spacetime diagram.

We have placed a stationary **Train** at $x = -0.25$ and set **Alice** moving to
the right at velocity $v = 0.5$. Move the **Time** slider to $t = 0.5$ and
watch the Observer View as the light rays expand, the event flashes, and Alice
passes the train!

> reset
> setup: v=0.0, t=0.0, mode=lorentz, tool=select
> object: event(name="E1", x=0.0, t=0.5, color=red)
> object: cone(name="L1", x=0.0, t=0.0, color=orange)
> object: train(name="Train", x=-0.25, t=0.0, v=0.0, color=green)
> object: person(name="Alice", x=0.0, t=0.0, v=0.5, color=blue)
> t = 0.5

## 7. Changing Observer Velocity

Below the time slider is the **Velocity** slider. It controls the velocity $v$
of our reference frame. Any newly added object automatically shares the current
observer velocity.

Move the **Velocity** slider to $v = 0.50$ to switch into Alice's frame of
reference.

> v = 0.5

## 8. Relativity of Motion

In Alice's reference frame ($v = 0.50$), Alice's worldline is vertical—she is
standing still—while the Train's worldline tilts to the left!

Because the laws of physics are relative, it is just as valid to say the train
moves past Alice as it is to return to $v = 0.0$ and say Alice moves past the
train.

Click **Continue** to finish the introduction!

> ok
