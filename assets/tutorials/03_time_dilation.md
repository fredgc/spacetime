# 3. Time Dilation & Moving Clocks

Discover why a moving clock ticks more slowly than a stationary clock, and how
relativity of simultaneity resolves the apparent symmetry paradox.

## 1. Alice's Light Clock

In Lesson 2 we saw that different observers disagree on which events happen at
the same time. Now let's see why they also measure time passing at different
rates.

We have placed **Alice** (with a clock at $x = 0.0$) and a **Mirror** (flag at
$x = 0.4$). At event **P1** $(0.0, 0.0)$, Alice flashes a beam of light. It
bounces off the mirror at **P2** $(0.4, 0.4)$ and returns to Alice at **P3**
$(0.0, 0.8)$. Click **Continue**.

> reset
> setup: v=0.0, t=0.0, mode=lorentz, tool=select
> object: clock(name="Alice", x=0.0, t=0.0, v=0.0, color=blue)
> object: flag(name="Mirror", x=0.4, t=0.0, v=0.0, color=teal)
> object: cone(name="L1", x=0.0, t=0.0, color=orange)
> object: cone(name="L2", x=0.4, t=0.4, color=orange)
> object: event(name="P1", x=0.0, t=0.0, color=green)
> object: event(name="P2", x=0.4, t=0.4, color=green)
> object: event(name="P3", x=0.0, t=0.8, color=green)
> ok

## 2. Check Alice's Clock at P3

Move the **Time** slider forward to $t = 0.8$ (event **P3**).

In the Observer View, notice that Alice's clock reads $t = 0.80$. That makes
sense: the mirror is $0.4$ units away and light travels at speed $1$, so the
round trip takes $0.4 + 0.4 = 0.8$ units of time.

> t = 0.8

## 3. Switch to Ben's Moving Frame

Now let's view these exact same events from the reference frame of **Ben**, an
observer moving at velocity $v = -0.60$ (where the Lorentz factor is
$\gamma = 1.25$).

Set the **Velocity** slider to $v = -0.60$.

> object: clock(name="Ben", x=0.0, t=0.0, v=-0.6, color=purple)
> v = -0.6

## 4. Light Travel Time for Ben

Look at the spacetime diagram in Ben's frame ($v = -0.60$):

* Both light beams still travel at speed $1$ ($45^\circ$ slopes).

* Because the Mirror is moving to the right away from the outgoing beam, the
  first leg (**P1** to **P2**) has farther to travel and takes $t = 0.80$.

* On the return leg (**P2** to **P3**), Alice is moving toward the reflected
  beam, so it takes only $0.20$ units of time.

Move the **Time** slider to $t = 1.0$ to reach event **P3** in Ben's frame.

> t = 1.0

## 5. Compare Ben's Clock and Alice's Clock

At event **P3** ($t = 1.0$ in Ben's frame), look at the two clocks in the
Observer View:

* **Ben's clock** reads $t = 1.00$ ($0.80 + 0.20$).

* **Alice's clock** at **P3** still reads $t = 0.80$!

Ben concludes that Alice's moving clock is running slow by a factor of
$\gamma = 1.25$. Click **Continue** to see why this doesn't cause a contradiction.

> ok

## 6. Marking Instants in Ben's Frame

By symmetry, shouldn't Alice also see Ben's clock running slow? To resolve this
paradox, we have added two horizontal **Instants** in Ben's reference frame:

* **I1** (red) at $t = 0.0$ (passing through **P1**, when both clocks read $0$).

* **I2** (purple) at $t = 1.0$ (passing through **P3**, when Ben's clock reads
  $1.00$ and Alice's reads $0.80$).

Now move the **Velocity** slider back to $v = 0.00$ to return to Alice's frame!

> object: instant(name="I1", x=0.0, t=0.0, v=-0.6, color=red)
> object: instant(name="I2", x=0.0, t=0.8, v=-0.6, color=purple)
> v = 0.0

## 7. Simultaneity Resolves the Paradox

In Alice's reference frame ($v = 0.00$), the lines **I1** and **I2** are no
longer horizontal!

Events along **I2** do *not* happen at the same time for Alice. At $t = 0.80$
in Alice's frame (when Alice reaches **P3**), Ben has not yet reached **I2**—in
Alice's frame, Ben's clock at $t = 0.80$ only reads $0.64$! Both observers see
the other's clock running slow because they measure "at the same time" along
different tilted planes of simultaneity.

> ok
