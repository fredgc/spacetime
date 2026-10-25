# 5. The Twin Paradox

Follow a pair of twins separating at relativistic speed and returning to see why
the traveling twin comes back younger.

## 1. Twins Separate at e1

Consider a pair of twins: **Alice** stays at rest ($v = 0.0$), while **Bob**
travels away to the right at $v = 0.60$ ($\gamma = 1.25$).

They start at the same place and time at event **e1** $(0.0, 0.0)$, so both
agree their clocks read $0.00$ at **e1**. When Bob's clock reads $0.40$, he
reaches turnaround event **e2** $(0.3, 0.5)$. Click **Continue**.

> reset
> setup: v=0.0, t=0.0, mode=lorentz, tool=select
> object: clock(name="Alice", x=0.0, t=0.0, v=0.0, color=blue)
> object: clock(name="Bob", x=0.0, t=0.0, v=0.6, color=green)
> object: event(name="e1", x=0.0, t=0.0, color=red)
> object: event(name="e2", x=0.3, t=0.5, color=red)
> ok

## 2. Introduce Returning Twin Carl

What happens when Bob turns around at **e2** and returns to Alice? Instead of
accelerating Bob, let's introduce a third observer, **Carl**, traveling in the
opposite direction at $v = -0.60$.

Set the **Velocity** slider to $v = -0.60$ (Carl's reference frame).

> v = -0.6

## 3. Synchronize Carl's Clock at e2

We have added **Carl** ($v = -0.60$) so that his worldline passes through
turnaround event **e2** and his clock matches Bob's clock at **e2** (both read
$t = 0.40$ at **e2**).

Carl's worldline continues to the left and meets Alice again at reunion event
**e3** $(0.0, 1.0)$. Click **Continue** to switch back to Alice's frame.

> object: clock(name="Carl", x=0.33, t=0.45, v=-0.6, color=purple)
> object: event(name="e3", x=0.0, t=1.0, color=red)
> ok

## 4. Return to Alice's Reference Frame

Move the **Velocity** slider to $v = 0.00$ so we are looking from Alice's rest
frame.

> v = 0.0

## 5. Compare Ages at the Reunion (e3)

Now move the **Time** slider forward to $t = 1.0$ to view the reunion event
**e3** where Carl and Alice meet.

Look at the clock readings in the lower Observer View at $t = 1.0$:

* **Carl's clock** reads $t = 0.80$ ($0.40$ outbound on Bob's clock plus $0.40$
  inbound on Carl's clock).

* **Alice's clock** reads $t = 1.00$!

When the traveling twin returns, he is younger than Alice.

> t = 1.0

## 6. Why Isn't It Symmetric?

Did Bob's or Carl's clock ever change speed? No—each ticked steadily in its own
inertial frame. Switch to Bob's reference frame by setting the **Velocity**
slider to $v = 0.60$.

> v = 0.6

## 7. Bob's Perspective

In Bob's frame ($v = 0.60$), Alice's clock *does* tick slower than Bob's.
However, Carl is moving even faster relative to Bob ($v_{\text{rel}} \approx
-0.88$), so Bob sees Carl's clock ticking much slower than Alice's!

Furthermore, in Bob's frame the return leg (**e2** to **e3**) takes much longer
than the outbound leg (**e1** to **e2**), giving Alice's clock plenty of time
to overtake Carl's clock before they meet at **e3**.

> ok
