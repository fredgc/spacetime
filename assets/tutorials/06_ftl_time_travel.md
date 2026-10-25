# 6. Faster-Than-Light & Time Travel

See why sending a faster-than-light or instantaneous message in special
relativity allows you to send a message back in time into your own past.

## 1. An Instantaneous Message (A1 to A2)

Suppose we had a device that could send an *instantaneous* (faster-than-light)
message in our own reference frame.

Here are two stationary observers, **A1** ($x = -0.5$) and **A2** ($x = 0.5$):

* **P1** $(-0.5, 0.5)$: **A1** creates a message.

* **P2** $(-0.5, 0.6)$: **A1** transmits the message instantaneously along the
  horizontal instant **MsgA** ($t = 0.6$).

* **P3** $(0.5, 0.6)$: **A2** receives the message at $t = 0.6$.

* **P4** $(0.5, 0.7)$: **A2** relays the message to a passing traveler.

Click **Continue**.

> reset
> setup: v=0.0, t=0.6, mode=lorentz, tool=select
> object: person(name="A1", x=-0.5, t=0.0, v=0.0, color=blue)
> object: person(name="A2", x=0.5, t=0.0, v=0.0, color=blue)
> object: event(name="P1", x=-0.5, t=0.5, color=red)
> object: event(name="P2", x=-0.5, t=0.6, color=red)
> object: instant(name="MsgA", x=0.0, t=0.6, v=0.0, color=orange)
> object: event(name="P3", x=0.5, t=0.6, color=red)
> object: event(name="P4", x=0.5, t=0.7, color=red)
> ok

## 2. Switch to a Moving Frame

Now let's introduce two moving observers, **B1** and **B2**, traveling to the
right at velocity $v = 0.60$. **B1** passes **A1** at event **P1**, and **B2**
passes **A2** at event **P4**.

Set the **Velocity** slider to $v = 0.60$ to switch into **B1** and **B2**'s
reference frame.

> object: person(name="B1", x=-0.5, t=0.5, v=0.6, color=green)
> object: person(name="B2", x=0.5, t=0.7, v=0.6, color=green)
> v = 0.6

## 3. P4 Happens Before P1!

Look closely at the vertical time order of **P4** and **P1** in the $v = 0.60$
reference frame:

* **P4** is at $t = 0.50$.

* **P1** is at $t = 1.00$.

In **B1** and **B2**'s reference frame, **A2** hands the message to **B2** at
**P4** *before* **A1** even created the message at **P1**! Move the **Time**
slider to $t = 0.70$ (halfway between **P4** and **P1**).

> t = 0.7

## 4. B2 Sends an Instantaneous Reply to B1

At time $t = 0.70$ in the $v = 0.60$ frame (event **P5** on **B2**'s
worldline), **B2** uses an identical instantaneous transmitter to send the
message along instant **MsgB** to **B1**, who receives it immediately at event
**P6** ($t = 0.70$).

Notice that **P6** is on **B1**'s worldline *below* (earlier than) event **P1**
($t = 1.00$)! Now set the **Velocity** slider back to $v = 0.00$.

> object: event(name="P5", x=0.65, t=0.95, color=red)
> object: instant(name="MsgB", x=0.65, t=0.95, v=0.6, color=purple)
> object: event(name="P6", x=-0.725, t=0.125, color=red)
> v = 0.0

## 5. A Closed Time Loop

Trace the full chain of events on the spacetime diagram:

$$\text{P1} \rightarrow \text{P2} \rightarrow \text{P3} \rightarrow \text{P4} \rightarrow \text{P5} \rightarrow \text{P6} \rightarrow \text{P1}$$

Because **B1** receives the message at **P6** ($t = 0.125$) and meets **A1** at
**P1** ($t = 0.50$), **B1** can hand the message to **A1** *before* **A1**
creates it at **P1**! Under special relativity, faster-than-light signaling in
any frame inevitably leads to backwards-in-time causal paradoxes.

> ok
