# 2. Constant Speed of Light & Relativity

What does it mean for the speed of light to be constant?

## 1. Ether vs. Emitter Speed

Before Einstein, scientists found that the speed of light was constant in a
vacuum. But constant relative to what?

Einstein started out with a thought experiment. If we are on a train, drinking
tea, leaving Trafalgar Station and emit a flash of light, is the light speed
relative to the ground, or relative to the train?

* **Ether Theory**: Light is a wave traveling through a stationary universal
  medium (the "luminiferous ether"). Its speed is always $c = 1$ relative to
  the ether, regardless of how fast the light source moves.

* **Emitter Theory**: Light consists of particles shot out from a source at
  speed $c = 1$ relative to the emitter. If an emitter moves at velocity $v$,
  its forward beam travels at $c + v$ and its backward beam at $c - v$.

Let's test both theories with a moving train. We'll look at the emitter
hypothesis first. I've added two flags in the $v=0$ reference frame. In the
next step we'll add a moving train that passes these flags.

Switch to **Use Emitter Speed**, and set our observer velocity to $v = 0.25$.

> reset
> setup: v=0.0, t=0.0, mode=lorentz, tool=select
> object: flag(name="BF", x=-0.25, t=0.0, v=0.0, color=teal)
> object: flag(name="FF", x=0.25, t=0.0, v=0.0, color=teal)
> mode = emitter
> v = 0.25

## 2. Train with Flashes at Each End

In this reference frame ($v = 0.25$), I have placed:

* A **Train** spanning from $x = -0.25$ to $x = 0.25$, centred at $x = 0.0$.

* Two inward light flashes (in orange) emitted from the back (**B**) and front
  (**F**) of the train at $t = 0.0$.

> setup: v=0.25, t=0.0, mode=emitter, tool=select
> object: train(name="Train", x=-0.25, t=0.0, v=0.25, color=purple)
> object: cone(name="B", x=-0.25, t=0.0, v=0.25, z=0.15, color=orange)
> object: cone(name="F", x=0.25, t=0.0, v=0.25, z=0.15, color=orange)

Advance the **Time** slider to $t = 0.25$.

Notice that the two flashes of light move at speed 1 in this frame. And the
two flashes meet in the middle of the train.

> t = 0.25

## 3. Emitter: View from the Ground

Switch to the ground's reference frame ($v = 0.0$) and go back to time $t =
0.0$.

Notice that the slope of the light flashes is different.

> v = 0.0
> t = 0.0

## 4. Emitter: Advance Time

Advance the **Time** slider to $t = 0.5$.

Notice that the two light flashes still meet at $t = 0.5$. But the two flashes
do not meet in the middle of the two flags. That's because one flash is faster
than the other.

> t = 0.5

## 5. Ether: View from the Ground

Go back to $t = 0.0$ and change to **Use Ether** mode.

> t = 0.0
> mode = ether

## 6. Ether: Flashes Meet in the Middle

Advance the **Time** slider to $t = 0.25$.

Notice that the flashes of light meet in the middle of the two flags. That's
because the speed of light is the same in the flags' reference frame.

> t = 0.25

## 7. Ether: View from the Train

Go back to $t = 0.0$ and switch to the train's reference frame ($v = 0.25$).

The light flashes start off at both ends of the train.

> t = 0.0
> v = 0.25

## 8. Ether: Flashes Miss the Middle of the Train

Advance the **Time** slider to $t = 0.25$.

Notice that the flashes do not meet in the middle of the train. That's because
the two flashes have different speeds in the train's reference frame.

> t = 0.25

## 9. Ether: Why the Beams Miss

In the **Ether** model, light travels at $c = 1$ relative to the stationary
ground ether, not the moving train.

Because the train moves forward through the ether at $v = 0.25$:

* The front beam (**F**) rushes toward the centre at speed $1 + 0.25 = 1.25$,
  reaching the middle early (at $t = 0.20$).

* The back beam (**B**) struggles to catch up at speed $1 - 0.25 = 0.75$,
  reaching the middle late (at $t = 0.33$).

Under ether theory, the two flashes do *not* collide in the middle of the
train!

Click **Continue** to learn about experimental results.

> ok

## 10. Experimental Results

Experiments found that the speed of light was the same in all reference
frames. This was true even if the emitter was moving or stationary!

Start the next tutorial to see one consequence of a speed of light that is the
same in all reference frames.

> ok
