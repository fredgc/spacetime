# 5. 长度收缩与车库悖论

探索运动物体如何在运动方向上发生空间收缩，以及相对论同时性如何化解车库悖论。

## 1. 静止系下的距离

两人**A1**（$x = -1.0$）和**A2**（$x = 1.0$）在静止系（$v = 0.00$）中间隔$2.0$单位。

> reset
> setup: v=0.0, t=0.0, mode=lorentz, tool=select
> object: person(name="A1", x=-1.0, t=0.0, v=0.0, color=blue)
> object: person(name="A2", x=1.0, t=0.0, v=0.0, color=blue)
> ok

## 2. 高速下的长度收缩

将**速度**调整至$v = 0.87$（$\gamma \approx 2.0$）。间距缩短为约$1.0$单位——缩小了一半！

> v = 0.87

## 3. 列车与车库情境

静止**车库**（$v = 0.0$，宽度$0.50$）与运动**列车**（$v = 0.60$，静止长度$0.50$）。将**速度**设为$v =
0.00$。

> reset
> setup: v=0.87, t=0.0, mode=lorentz, tool=select
> object: barn(name="Barn", x=-0.25, t=0.0, v=0.0, color=green)
> object: train(name="Train", x=-0.20, t=0.0, v=0.6, color=orange)
> v = 0.0

## 4. 列车完全处于车库内部

在车库系中，列车在$t = 0.0$时收缩至$0.40$（$x = -0.20$至$0.20$），完全容纳在车库内！添加**事件**标记车头位置$(x =
0.2, t = 0.0)$。

> object: event(name="B", x=-0.20, t=0.0, color=red)
> add = event(x=0.2, t=0.0)

## 5. 切换到列车参考系

将**速度**设置为$v = 0.60$。列车长度为$0.50$，而车库收缩为$0.40$——列车比车库更长！

> reset
> setup: v=0.0, t=0.0, mode=lorentz, tool=select
> object: barn(name="Barn", x=-0.25, t=0.0, v=0.0, color=green)
> object: train(name="Train", x=-0.20, t=0.0, v=0.6, color=orange)
> object: event(name="B", x=-0.20, t=0.0, color=red)
> object: event(name="F", x=0.20, t=0.0, color=blue)
> v = 0.6

## 6. 车头率先到达出口

在列车系中，**F**与**B**不同时发生！在$t = -0.15$（**F**）时车头已到门边，而车尾还在车库外面。

> t = -0.15

## 7. 车尾随后进入

在$t = 0.15$（**B**）时车尾进入车库，此时车头早已开出车库！两个事件仅在车库参考系中同时发生。

> t = 0.15
