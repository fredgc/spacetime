# 3. Constant Speed of Light & Simultaneity

Discover why different observers disagree on whether two events happen at the
same time, and how this relativity of simultaneity is the necessary
consequence of a constant speed of light.

## 1. Train with a Center Light Flash

Let's start in the reference frame of a train moving at $v = 0.25$.

We ride along inside the train ($v = 0.25$). The purple train spans from
$x = -0.25$ to $x = 0.25$ (rest length $0.50$), centered at $x = 0.0$.

Switch to **Add**, choose **Light Cone**, and click in the lower Observer View
(side view) at the center of the train $(x = 0.0, z = 0.15)$ to emit a flash of
light inside the train (or click **Do it for me**).

> reset
> setup: v=0.25, t=0.0, mode=lorentz, tool=add, type=cone
> object: train(name="Train", x=-0.25, t=0.0, v=0.25, color=purple)
> add = cone(name="Flash", x=0.0, t=0.0, z=0.15, color=orange, side=true)

## 2. Simultaneous Hits in the Train Frame

Advance the **Time** slider to $t = 0.25$.

In the train's reference frame, light expands outward at speed $c = 1$ in both
directions. The back and front of the train are both $0.25$ units away from the
center.

Look at the Observer View below: the two flashes hit both ends of the train at
the exact same instant ($t = 0.25$)!

> t = 0.25

## 3. Switch to the Ground Frame

Now let's view this scene from the ground. Move the **Velocity** slider to
$v = 0.00$ and reset the **Time** slider to $t = 0.00$.

Notice that under special relativity (**Use Lorentz**), light still travels at
speed $c = 1$ ($45^\circ$ slopes) even though the train is moving!

> v = 0.0
> t = 0.0

## 4. Light Hits the Back of the Train

Advance the **Time** slider forward to $t = 0.19$.

In the ground frame, the train is moving forward (to the right) at $v = 0.25$.
Its back end rushes toward the backward-traveling light ray, meeting it early
at $t \approx 0.19$ (at $x \approx -0.19$).

Notice in the Observer View that the light has already reached the back of the
train, while the front beam is still chasing the front of the train!

> t = 0.19

## 5. Mark Event B

Let's mark this event in spacetime. Switch to **Add**, choose **Event**, and
click the intersection at $(x = -0.19, t = 0.19)$ to place Event **B** (or
click **Do it for me**).

> add = event(name="B", x=-0.19, t=0.19, color=red)

## 6. Light Hits the Front of the Train

Now advance the **Time** slider forward to $t = 0.32$.

Because the front of the train was moving away from the light flash, the forward
beam took longer to catch up, finally striking the front of the train at
$t \approx 0.32$ (at $x \approx 0.32$).

> t = 0.32

## 7. Mark Event F

Mark this second event where light hits the front of the train. Click the
intersection at $(x = 0.32, t = 0.32)$ to place Event **F** (or click **Do it
for me**).

> add = event(name="F", x=0.32, t=0.32, color=green)

## 8. Return to the Train Frame

We have labeled the two hit events: **B** (red) and **F** (green).

Now move the observer **Velocity** slider back to $v = 0.25$ to return to the
train's rest frame.

> reset
> setup: v=0.0, t=0.32, mode=lorentz, tool=select
> object: train(name="Train", x=-0.25, t=0.0, v=0.25, color=purple)
> object: cone(name="Flash", x=0.0, t=0.0, z=0.15, color=orange)
> object: event(name="B", x=-0.19, t=0.19, color=red)
> object: event(name="F", x=0.32, t=0.32, color=green)
> v = 0.25

## 9. Simultaneous Again!

Set the **Time** slider to $t = 0.25$.

Look at the spacetime diagram and the Observer View:
In the train's frame ($v = 0.25$), both **B** and **F** happen at the exact same
time $t = 0.25$!

Try toggling **Velocity** between $v = 0.25$ and $v = 0.00$. When you switch
reference frames, the line of simultaneity tilts:

* In the train's frame, the two events are **simultaneous** ($t = 0.25$).

* In the ground frame, **B** happens *first* ($t = 0.19$) and **F** happens
  *second* ($t = 0.32$).

> t = 0.25

## 10. Relativity of Simultaneity

If light has the same speed in all reference frames under the Lorentz
transformation, then whether two separated events happen at the "same time"
depends on the observer!

Absolute simultaneity does not exist. Observers in relative motion will disagree
on the time order of distant events.

Click **Continue** to complete the tutorial.

> ok
