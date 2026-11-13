# 4. 時間の遅れと運動する時計

なぜ運動する時計が静止した時計よりも遅く進むのか、そして同時性の相対性がそのパラドックスをどう解消するかを学びます。

## 1. Alice の光時計

時計を持つ**Alice**（$x = 0.0$）と**反射鏡**（$x = 0.4$）を配置しました。**P1** $(0.0, 0.0)$で発した光が鏡
**P2** $(0.4, 0.4)$で反射し、**P3** $(0.0, 0.8)$で戻ります。

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

## 2. P3 での Alice の時計確認

**時間**を$t = 0.8$（事象**P3**）に進めます。Aliceの時計は$t = 0.80$を指しています（$0.4 + 0.4 = 0.8$）。

> t = 0.8

## 3. 運動する Ben の基準系へ

$v = -0.60$（$\gamma = 1.25$）で動く観測者**Ben**の視点に切り替えます。**速度**を$v = -0.60$に設定します。

> object: clock(name="Ben", x=0.0, t=0.0, v=-0.6, color=purple)
> v = -0.6

## 4. Ben から見た光の所要時間

鏡が逃げるため往路（**P1**〜**P2**）は$t = 0.80$かかり、復路はAliceが近づくため$0.20$で済みます。**時間**を$t =
1.0$に進めます。

> t = 1.0

## 5. 時計の比較

事象**P3**（Ben系での$t = 1.0$）において：

* **Benの時計**は$t = 1.00$。

* **Aliceの時計**はまだ$t = 0.80$！

Benから見ると、運動するAliceの時計は$\gamma = 1.25$倍遅れて進みます。

> ok

## 6. Ben の同時面の確認

Benの系に2つの**同時面** **I1**（$t = 0.0$）と**I2**（$t = 1.0$）を置きました。Aliceの系（$v =
0.00$）に戻ります。

> object: instant(name="I1", x=0.0, t=0.0, v=-0.6, color=red)
> object: instant(name="I2", x=0.0, t=0.8, v=-0.6, color=purple)
> v = 0.0

## 7. 同時性がパラドックスを解消する

Aliceの系では**I1**と**I2**は水平ではありません！Aliceが$t = 0.80$のとき、Benの時計は$0.64$しか指していません。双方
が「相手の時計が遅れている」と見るのは、同時面が互いに傾いているためです。

> ok
