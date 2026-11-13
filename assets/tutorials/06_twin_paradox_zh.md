# 6. 双生子悖论

跟随以相对论速度分离并重新相聚的双胞胎，理解为什么旅行的双胞胎返回时更年轻。

## 1. 在 e1 处分离

**Alice**留在原地（$v = 0.0$），而**Bob**以$v = 0.60$（$\gamma = 1.25$）启程旅行。两人在**e1**
$(0.0, 0.0)$处校准时钟。在Bob的时钟显示$0.40$时，他到达折返点**e2** $(0.3, 0.5)$。

> reset
> setup: v=0.0, t=0.0, mode=lorentz, tool=select
> object: clock(name="Alice", x=0.0, t=0.0, v=0.0, z=0.05, color=blue)
> object: clock(name="Bob", x=0.0, t=0.0, v=0.6, z=0.2, color=green)
> object: event(name="e1", x=0.0, t=0.0, z=0.0, color=red)
> object: event(name="e2", x=0.3, t=0.5, z=0.0, color=red)
> ok

## 2. 引入返程观察者 Carl

为了避免加速过程的复杂性，引入反向运动的第三位观察者**Carl**（$v = -0.60$）。将**速度**设为$v = -0.60$。

> v = -0.6

## 3. 在 e2 处同步 Carl 的时钟

Carl的世界线经过**e2**并与Bob的时钟同步（显示$0.40$）。Carl在**e3** $(0.0, 1.0)$与Alice相遇。

> object: clock(name="Carl", x=0.33, t=0.45, v=-0.6, z=0.15, color=purple)
> object: event(name="e3", x=0.0, t=1.0, z=0.0, color=red)
> ok

## 4. 返回 Alice 的静止系

将**速度**设为$v = 0.00$。

> v = 0.0

## 5. 重聚（e3）时的年龄对比

将**时间**推至$t = 1.0$：

* **Carl的时钟**显示$t = 0.80$（$0.40$去程$+ 0.40$返程）。

* **Alice的时钟**显示$t = 1.00$！

旅行的双胞胎确实比留在家中的Alice更年轻。

> t = 1.0

## 6. 为什么该过程并不对称？

在Bob参考系中，Alice的时钟虽然变慢，但Carl相对Bob的速度极大（$v_{\text{rel}} \approx -0.88$），因而Carl的时
钟走得更慢。更关键的是，在该参考系中返程所经历的时间远大于去程时间。

> ok
