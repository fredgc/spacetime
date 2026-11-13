# 5. ローレンツ収縮と車庫のパラドックス

運動する物体が進行方向に縮む様子と、同時性の相対性が車庫のパラドックスを解決する仕組みを学びます。

## 1. 静止系での距離

静止系（$v = 0.00$）で2人の観測者**A1**（$x = -1.0$）と**A2**（$x = 1.0$）の間隔は$2.0$あります。

> reset
> setup: v=0.0, t=0.0, mode=lorentz, tool=select
> object: person(name="A1", x=-1.0, t=0.0, v=0.0, color=blue)
> object: person(name="A2", x=1.0, t=0.0, v=0.0, color=blue)
> ok

## 2. 高速運動による長さの収縮

**速度**を$v = 0.87$（$\gamma \approx 2.0$）にします。2人の間隔は約$1.0$（半分）に縮みます！

> v = 0.87

## 3. 列車と車庫の設定

静止した**車庫**（$v = 0.0$、幅$0.50$）と運動する**列車**（$v = 0.60$、静止幅$0.50$）です。**速度**を$v =
0.00$にします。

> reset
> setup: v=0.87, t=0.0, mode=lorentz, tool=select
> object: barn(name="Barn", x=-0.25, t=0.0, v=0.0, color=green)
> object: train(name="Train", x=-0.20, t=0.0, v=0.6, color=orange)
> v = 0.0

## 4. 車庫に収まる列車

車庫系では$t = 0.0$に列車が$0.40$（$x = -0.20$〜$0.20$）に収縮し、車庫に完全に収まります！$(x = 0.2, t =
0.0)$に**事象**を追加してください。

> object: event(name="B", x=-0.20, t=0.0, color=red)
> add = event(x=0.2, t=0.0)

## 5. 列車の基準系へ切り替え

**速度**を$v = 0.60$にします。列車は長さ$0.50$、車庫が$0.40$に縮むため、列車の方が長くなります！

> reset
> setup: v=0.0, t=0.0, mode=lorentz, tool=select
> object: barn(name="Barn", x=-0.25, t=0.0, v=0.0, color=green)
> object: train(name="Train", x=-0.20, t=0.0, v=0.6, color=orange)
> object: event(name="B", x=-0.20, t=0.0, color=red)
> object: event(name="F", x=0.20, t=0.0, color=blue)
> v = 0.6

## 6. 前端が先に出口に到達

列車系では**F**と**B**は同時ではありません！$t = -0.15$（**F**）で前端が出口に到達したとき、後端はまだ車庫の外です。

> t = -0.15

## 7. 後端が遅れて入る

$t = 0.15$（**B**）に後端が入ったときには、前端はすでに車庫の外へ出ています！両事象は車庫系においてのみ同時に起こります。

> t = 0.15
