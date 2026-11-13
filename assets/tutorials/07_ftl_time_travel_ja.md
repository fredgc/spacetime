# 7. 超光速信号と時間旅行

特殊相対論において、超光速または瞬時の通信を行うと、なぜ過去の自分へメッセージを送れてしまうのかを体験します。

## 1. 瞬時通信（A1 から A2 へ）

2人の静止観測者：**A1**（$x = -0.5$）と**A2**（$x = 0.5$）。

* **P1**：A1が手紙を書く。

* **P2**：A1が水平な同時面**MsgA**で瞬時送信（$t = 0.6$）。

* **P3**：A2が$t = 0.6$で受信。

* **P4**：A2が通過する旅人に手紙を渡す。

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

## 2. 運動する基準系へ切り替え

$v = 0.60$で動く観測者**B1**と**B2**。**速度**を$v = 0.60$にします。

> object: person(name="B1", x=-0.5, t=0.5, v=0.6, color=green)
> object: person(name="B2", x=0.5, t=0.7, v=0.6, color=green)
> v = 0.6

## 3. P4 は P1 より前に起きる！

運動系では**P4**は$t = 0.50$、**P1**は$t = 1.00$です。A1が手紙を書く*前*にA2はすでにB2に手紙を渡しています！**時間
**を$t = 0.70$にします。

> t = 0.7

## 4. B2 が B1 へ瞬時返信

B2が**MsgB**でB1に返信し、B1は**P6**（$t = 0.70$）で受信します。**速度**を$v = 0.00$に戻します。

> object: event(name="P5", x=0.65, t=0.95, z=0.15, color=red)
> object: instant(name="MsgB", x=0.65, t=0.95, v=0.6, color=purple)
> object: event(name="P6", x=-0.725, t=0.125, color=red)
> v = 0.0

## 5. 閉じた時間のループ

$$\text{P1} \rightarrow \text{P2} \rightarrow \text{P3} \rightarrow \text{P4} \rightarrow \text{P5} \rightarrow \text{P6} \rightarrow \text{P1}$$

B1は$t = 0.125$に返信を受け取り、A1が$t = 0.50$で手紙を書く*前*にそれをA1に手渡せます！超光速通信は因果律の崩壊を招きます。

> ok
