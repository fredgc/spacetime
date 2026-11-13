# 7. 超光速信号与时间倒流

了解为什么在狭义相对论中，发送超光速或瞬时信号必然允许人们向自己的过去发送信息。

## 1. 瞬时信号（从 A1 到 A2）

两位静止观察者：**A1**（$x = -0.5$）与**A2**（$x = 0.5$）。

* **P1**：A1撰写信息。

* **P2**：A1沿水平瞬时面**MsgA**瞬时发送信息（$t = 0.6$）。

* **P3**：A2在$t = 0.6$收到信息。

* **P4**：A2将信息转交信使。

> reset
> setup: v=0.0, t=0.6, mode=lorentz, tool=select
> object: person(name="A1", x=-0.5, t=0.0, v=0.0, color=blue)
> object: person(name="A2", x=0.5, t=0.0, v=0.0, color=blue)
> object: event(name="P1", x=-0.5, t=0.5, z=0.15, color=red)
> object: event(name="P2", x=-0.5, t=0.6, z=0.15, color=red)
> object: instant(name="MsgA", x=0.0, t=0.6, v=0.0, color=orange)
> object: event(name="P3", x=0.5, t=0.6, z=0.15, color=red)
> object: event(name="P4", x=0.5, t=0.7, z=0.15, color=red)
> ok

## 2. 切换至运动参考系

两位以$v = 0.60$运动的观察者**B1**和**B2**。将**速度**设为$v = 0.60$。

> object: person(name="B1", x=-0.5, t=0.5, v=0.6, color=green)
> object: person(name="B2", x=0.5, t=0.7, v=0.6, color=green)
> v = 0.6

## 3. P4 发生在 P1 之前！

在运动参考系中，**P4**的时间为$t = 0.50$，而**P1**为$t = 1.00$。这意味着A2在A1甚至还没写出信息之前，就已经把信息转交给了
B2！将时间推至$t = 0.70$。

> t = 0.7

## 4. B2 向 B1 发送瞬时回复

B2沿瞬时面**MsgB**向B1发送回复，B1在**P6**（$t = 0.70$）收到信息。将**速度**调回$v = 0.00$。

> object: event(name="P5", x=0.65, t=0.95, z=0.15, color=red)
> object: instant(name="MsgB", x=0.65, t=0.95, v=0.6, color=purple)
> object: event(name="P6", x=-0.725, t=0.125, color=red)
> v = 0.0

## 5. 闭合类时闭环

$$\text{P1} \rightarrow \text{P2} \rightarrow \text{P3} \rightarrow \text{P4} \rightarrow \text{P5} \rightarrow \text{P6} \rightarrow \text{P1}$$

B1在$t = 0.125$收到回复，并可以在A1于$t = 0.50$写信*之前*将信交给A1！超光速通信必然破坏因果律。

> ok
