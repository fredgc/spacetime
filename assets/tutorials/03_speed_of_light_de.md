# 3. Konstante Lichtgeschwindigkeit & Gleichzeitigkeit

Entdecken Sie, warum verschiedene Beobachter uneinig darüber sind, ob zwei
Ereignisse gleichzeitig stattfinden, und warum die Relativität der
Gleichzeitigkeit eine zwingende Folge der konstanten Lichtgeschwindigkeit ist.

## 1. Zug mit zentralem Lichtblitz

Wir beginnen im Bezugssystem eines Zuges, der mit $v = 0.25$ fährt.

Wir fahren im Zug mit ($v = 0.25$). Der lilafarbene Zug erstreckt sich von $x
= -0.25$ bis $x = 0.25$ (Ruhelänge $0.50$), zentriert bei $x = 0.0$.

Wählen Sie **Hinzufügen**, dann **Lichtkegel**, und klicken Sie in der unteren
Beobachteransicht in die Mitte des Zuges $(x = 0.0, z = 0.15)$, um einen
Lichtblitz im Zug auszusenden (oder klicken Sie auf **Für mich ausführen**).

> reset
> setup: v=0.25, t=0.0, mode=lorentz, tool=add, type=cone
> object: train(name="Train", x=-0.25, t=0.0, v=0.25, color=purple)
> add = cone(name="Flash", x=0.0, t=0.0, z=0.15, color=orange, side=true)

## 2. Gleichzeitiges Eintreffen im Zugsystem

Bewegen Sie den **Zeit**-Schieberegler auf $t = 0.25$.

Im Ruhesystem des Zuges breitet sich das Licht in beide Richtungen mit $c = 1$
aus. Beide Enden sind $0.25$ Einheiten von der Mitte entfernt.

Die beiden Blitze treffen beide Zugenden im exakt selben Moment ($t = 0.25$)!

> t = 0.25

## 3. Wechsel ins Ruhesystem des Bodens

Betrachten wir die Szene vom Boden aus. Setzen Sie den
**Geschwindigkeit**-Schieberegler auf $v = 0.00$ und die Zeit auf $t = 0.00$.

Unter der speziellen Relativitätstheorie (**Lorentz**) breitet sich das Licht
auch vom Boden aus mit $c = 1$ ($45^\circ$-Winkel) aus, obwohl der Zug fährt!

> v = 0.0
> t = 0.0

## 4. Licht trifft das Zugende

Bewegen Sie den **Zeit**-Schieberegler auf $t = 0.19$.

Im Bodensystem fährt der Zug nach rechts ($v = 0.25$). Sein hinteres Ende eilt
dem Lichtstrahl entgegen und trifft ihn frühzeitig bei $t \approx 0.19$ (bei
$x \approx -0.19$).

> t = 0.19

## 5. Ereignis B markieren

Wechseln Sie zu **Hinzufügen**, wählen Sie **Ereignis** und platzieren Sie
Ereignis **B** bei $(x = -0.19, t = 0.19)$.

> add = event(name="B", x=-0.19, t=0.19, color=red)

## 6. Licht trifft die Zugspitze

Bewegen Sie den **Zeit**-Schieberegler vorwärts auf $t = 0.32$.

Da die Zugspitze vor dem Lichtstrahl davonfährt, benötigt der Strahl länger
und trifft die Spitze erst bei $t \approx 0.32$ (bei $x \approx 0.32$).

> t = 0.32

## 7. Ereignis F markieren

Markieren Sie das Eintreffen an der Spitze: Platzieren Sie Ereignis **F** bei
$(x = 0.32, t = 0.32)$.

> add = event(name="F", x=0.32, t=0.32, color=green)

## 8. Zurück ins Zugsystem

Wir haben beide Treffereignisse markiert: **B** (rot) und **F** (grün).

Setzen Sie die **Geschwindigkeit** wieder auf $v = 0.25$, um ins Ruhesystem
des Zuges zurückzukehren.

> reset
> setup: v=0.0, t=0.32, mode=lorentz, tool=select
> object: train(name="Train", x=-0.25, t=0.0, v=0.25, color=purple)
> object: cone(name="Flash", x=0.0, t=0.0, z=0.15, color=orange)
> object: event(name="B", x=-0.19, t=0.19, color=red)
> object: event(name="F", x=0.32, t=0.32, color=green)
> v = 0.25

## 9. Wieder gleichzeitig!

Setzen Sie den **Zeit**-Schieberegler auf $t = 0.25$.

Im Zugsystem ($v = 0.25$) finden sowohl **B** als auch **F** zur exakt selben
Zeit $t = 0.25$ statt!

Beim Wechsel zwischen den Bezugssystemen kippt die Gleichzeitigkeitslinie:

* Im Zugsystem sind die Ereignisse **gleichzeitig** ($t = 0.25$).

* Im Bodensystem geschieht **B** *zuerst* ($t = 0.19$) und **F** *danach* ($t
  = 0.32$).

> t = 0.25

## 10. Relativität der Gleichzeitigkeit

Wenn Licht in allen Bezugssystemen dieselbe Geschwindigkeit hat, hängt die
Gleichzeitigkeit zweier getrennter Ereignisse vom Beobachter ab!

Eine absolute Gleichzeitigkeit existiert nicht.

Klicken Sie auf **Weiter**, um das Tutorial abzuschließen.

> ok
