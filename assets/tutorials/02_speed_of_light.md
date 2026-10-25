# 2. Constant Speed of Light & Simultaneity

Use flashes of light to find a midpoint and discover why different observers
disagree on which events happen at the same time.

## 1. Two Flashes of Light

If the speed of light is constant ($c = 1$), we can use light rays to find the
midpoint between two people.

Here are two stationary observers, **P1** (at $x = -1.0$) and **P2** (at
$x = 1.0$). At time $t = 0.0$, each flashes a beam of light (**L1** and
**L2**). Click **Continue** to see where the beams meet.

> reset
> setup: v=0.0, t=0.0, mode=lorentz, tool=select
> object: person(name="P1", x=-1.0, t=0.0, v=0.0, color=green)
> object: person(name="P2", x=1.0, t=0.0, v=0.0, color=green)
> object: cone(name="L1", x=-1.0, t=0.0, color=orange)
> object: cone(name="L2", x=1.0, t=0.0, color=orange)
> ok

## 2. Advance Time to the Intersection

Move the **Time** slider forward to $t = 1.0$. Watch the inward-moving arrows
of **L1** and **L2** in the lower Observer View meet right at the midpoint
$x = 0.0$.

> t = 1.0

## 3. Mark the Meeting Point

Let's mark the spacetime point where the two light cones cross. Switch to
**Add**, select **Event**, and click the intersection at $(x = 0.0, t = 1.0)$
(or click **Do it for me**).

> add = event(x=0.0, t=1.0)

## 4. Add a Midpoint Observer

We have labeled the intersection event **X** (in red) and placed a third person
**M** (in blue) at the midpoint $x = 0.0$. Notice that **M**'s vertical
worldline passes directly through **X**.

Move the **Time** slider back to $t = 0.0$.

> reset
> setup: v=0.0, t=1.0, mode=lorentz, tool=select
> object: person(name="P1", x=-1.0, t=0.0, v=0.0, color=green)
> object: person(name="P2", x=1.0, t=0.0, v=0.0, color=green)
> object: cone(name="L1", x=-1.0, t=0.0, color=orange)
> object: cone(name="L2", x=1.0, t=0.0, color=orange)
> object: event(name="X", x=0.0, t=1.0, color=red)
> object: person(name="M", x=0.0, t=0.0, v=0.0, color=blue)
> t = 0.0

## 5. Turn Off Lorentz (Classical Ether)

What would happen in classical Newtonian physics without the Lorentz
transformation? Open the menu drawer (`☰` → **View**) and select **Use Ether**.

> mode = ether

## 6. Observe the Classical Paradox

Now set the observer **Velocity** slider to $v = 0.40$ to see how this diagram
looks in a moving frame under classical physics.

> v = 0.4

## 7. Restore the Lorentz Transformation

With the Lorentz transformation turned off, changing observer velocity shifts
the light rays relative to the observers—creating a physical contradiction!

Re-enable special relativity by opening `☰` → **View** and selecting **Use
Lorentz**.

> mode = lorentz

## 8. Relativity of Simultaneity

With **Use Lorentz** active at $v = 0.40$, both light beams travel at speed
$c = 1$ (45° slopes) and still meet at event **X** on **M**'s worldline!

Look at the origins of **L1** and **L2** in this moving frame: **P1** flashed
its light *after* **P2** ($t_{L1} > 0$ while $t_{L2} < 0$). While **P1**,
**P2**, and **M** agree the flashes were simultaneous, a moving observer does
not. Saying two events happen at the "same time" is relative to the observer!

> ok
