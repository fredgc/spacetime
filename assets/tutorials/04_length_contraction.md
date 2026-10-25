# 4. Length Contraction & the Train-Barn Paradox

Explore how moving objects contract along their direction of motion and how
relativity of simultaneity resolves the classic Train-and-Barn paradox.

## 1. Distance in a Rest Frame

We have placed two stationary people, **A1** at $x = -1.0$ and **A2** at
$x = 1.0$. In their own reference frame ($v = 0.00$), the distance between them
is $2.0$ units.

Click **Continue** to see what happens to their separation when viewed from a
moving frame.

> reset
> setup: v=0.0, t=0.0, mode=lorentz, tool=select
> object: person(name="A1", x=-1.0, t=0.0, v=0.0, color=blue)
> object: person(name="A2", x=1.0, t=0.0, v=0.0, color=blue)
> ok

## 2. Length Contraction at High Speed

Move the **Velocity** slider to $v = 0.87$, where the Lorentz scaling factor
$\gamma = 1 / \sqrt{1 - v^2}$ is approximately $2.0$.

Notice in both the spacetime diagram and the Observer View that **A1** and
**A2** are now only about $1.0$ unit apart—half their rest distance!

> v = 0.87

## 3. The Train and Barn Setup

Just like time dilation, length contraction seems to create a paradox: if the
barn sees the moving train as shorter, and the train sees the barn as shorter,
does the train fit inside the barn?

Here is a stationary **Barn** ($v = 0.0$, width $0.50$, spanning $x = -0.25$ to
$0.25$) and a moving **Train** ($v = 0.60$, rest width $0.50$). Set the
**Velocity** slider to $v = 0.00$ to view the Barn's rest frame.

> reset
> setup: v=0.87, t=0.0, mode=lorentz, tool=select
> object: barn(name="Barn", x=-0.25, t=0.0, v=0.0, color=green)
> object: train(name="Train", x=-0.20, t=0.0, v=0.6, color=orange)
> v = 0.0

## 4. Mark the Train Inside the Barn

In the Barn's frame ($v = 0.00$) at $t = 0.0$, the moving Train is contracted
by $\sqrt{1 - 0.6^2} = 0.8$ to a width of $0.40$ (spanning $x = -0.20$ to
$0.20$), so it fits completely inside the Barn!

We placed a red event **Back** at $(-0.20, 0.0)$ where the back of the train is
inside the left door. Add an **Event** at $(x = 0.2, t = 0.0)$ to mark the
front of the train inside the right door.

> object: event(name="Back", x=-0.20, t=0.0, color=red)
> add = event(x=0.2, t=0.0)

## 5. Switch to the Train's Frame

Now set the **Velocity** slider to $v = 0.60$ to look from the Train's
reference frame.

In this frame, the Train has its full width ($0.50$) while the Barn is
contracted to $0.40$—the Train is *longer* than the Barn! What happened to our
two events **Back** (red) and **Front** (blue)?

> reset
> setup: v=0.0, t=0.0, mode=lorentz, tool=select
> object: barn(name="Barn", x=-0.25, t=0.0, v=0.0, color=green)
> object: train(name="Train", x=-0.20, t=0.0, v=0.6, color=orange)
> object: event(name="Back", x=-0.20, t=0.0, color=red)
> object: event(name="Front", x=0.20, t=0.0, color=blue)
> v = 0.6

## 6. Front Reaches the Exit First

In the Train's frame ($v = 0.60$), **Front** and **Back** do *not* happen at
the same time!

Move the **Time** slider to $t = -0.15$ (when **Front** occurs). Look at the
Observer View: the front of the train is at the right edge of the barn, while
the back of the train is still outside to the left.

> t = -0.15

## 7. Back Enters Later

Now move the **Time** slider forward to $t = 0.15$ (when **Back** occurs).

By the time the back of the train is inside the left door of the barn, the
front of the train has already passed well beyond the right door! Both frames
agree on the events **Front** and **Back**, but they only happen simultaneously
in the Barn's reference frame.

> t = 0.15
