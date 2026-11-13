# 4. 时间膨胀与运动时钟

探索为什么运动的时钟比静止的时钟走得慢，以及同时性的相对性如何化解佯谬。

## 1. Alice 的光钟

我们放置了**Alice**（带着时钟位于$x = 0.0$）和一面**反射镜**（$x = 0.4$）。在**P1** $(0.0, 0.0)$处发出光脉
冲，经反射镜**P2** $(0.4, 0.4)$反射并在**P3** $(0.0, 0.8)$返回。

> reset
> setup: v=0.0, t=0.0, mode=lorentz, tool=select
> object: clock(name="Alice", x=0.0, t=0.0, z=0.125, v=0.0, color=blue)
> object: flag(name="Mirror", x=0.4, t=0.0, v=0.0, color=teal)
> object: cone(name="L1", x=0.0, t=0.0, color=orange)
> object: cone(name="L2", x=0.4, t=0.4, color=orange)
> object: event(name="P1", x=0.0, t=0.0, color=green)
> object: event(name="P2", x=0.4, t=0.4, color=green)
> object: event(name="P3", x=0.0, t=0.8, color=green)
> ok

## 2. 检查 Alice 在 P3 的时钟

推进**时间**至$t = 0.8$（事件**P3**）。Alice的时钟显示$t = 0.80$（$0.4 + 0.4 = 0.8$）。

> t = 0.8

## 3. 切换至 Ben 的运动参考系

以相对速度$v = -0.60$（$\gamma = 1.25$）运动的观察者**Ben**的视角来观察。将**速度**设为$v = -0.60$。

> object: clock(name="Ben", x=0.0, t=0.0, v=-0.6, color=purple)
> v = -0.6

## 4. Ben 测量的光行时间

在Ben的参考系中，反射镜远离光束运动，去程花费$t = 0.80$；回程Alice迎面而来，仅需$0.20$。将**时间**推至$t = 1.0$。

> t = 1.0

## 5. 比较两个时钟

在事件**P3**（Ben系的$t = 1.0$）处：

* **Ben的时钟**显示$t = 1.00$。

* **Alice的时钟**依然显示$t = 0.80$！

Ben观察到运动中的Alice的时钟变慢了$\gamma = 1.25$倍。

> ok

## 6. 在 Ben 的参考系中标记瞬时面

添加两个**瞬时面**：**I1**（$t = 0.0$）和**I2**（$t = 1.0$）。切回Alice的参考系（$v = 0.00$）。

> object: instant(name="I1", x=0.0, t=0.0, v=-0.6, color=red)
> object: instant(name="I2", x=0.0, t=0.8, v=-0.6, color=purple)
> v = 0.0

## 7. 同时性化解佯谬

在Alice参考系中，**I1**与**I2**不再水平！在Alice达到$t = 0.80$时，Ben的时钟仅为$0.64$。双方都看到对方的时钟变慢，这
是同时性平面倾斜的几何必然。

> ok
