# 2. Konstante Lichtgeschwindigkeit & Relativität

Was bedeutet es, dass die Lichtgeschwindigkeit konstant ist?

## 1. Äther vs. Emitter-Geschwindigkeit

Vor Einstein stellten Wissenschaftler fest, dass die Lichtgeschwindigkeit im
Vakuum konstant ist. Doch konstant relativ wozu?

Einstein begann mit einem Gedankenexperiment: Wenn wir in einem Zug sitzen,
ein Bier trinken, den Berliner Hauptbahnhof verlassen und einen Lichtblitz
aussenden–ist die Lichtgeschwindigkeit dann relativ zum Erdboden oder relativ
zum Zug?

* **Äthertheorie**: Licht ist eine Welle, die sich durch ein ruhendes
  universelles Medium (den„Lichtäther“) ausbreitet. Seine Geschwindigkeit ist
  relativ zumÄther stets $c = 1$, unabhängig von der Bewegung der Lichtquelle.

* **Emittertheorie**: Licht besteht aus Teilchen, die von einer Quelle mit der
  Geschwindigkeit $c = 1$ relativ zum Emitter abgestrahlt werden. Bewegt sich
  eine Quelle mit $v$, breitet sich der Strahl nach vorn mit $c + v$ und nach
  hinten mit $c - v$ aus.

Lassen Sie uns beide Theorien mit einem fahrenden Zug testen. Zuerst
betrachten wir die Emitterhypothese. Ich habe zwei Flaggen im Bezugssystem
$v=0$ platziert. Als Nächstes fügen wir einen fahrenden Zug hinzu.

Wechseln Sie zu **Emitter-Geschwindigkeit verwenden** und setzen Sie die
Beobachtergeschwindigkeit auf $v = 0.25$.

> reset
> setup: v=0.0, t=0.0, mode=lorentz, tool=select
> object: flag(name="BF", x=-0.25, t=0.0, v=0.0, color=teal)
> object: flag(name="FF", x=0.25, t=0.0, v=0.0, color=teal)
> mode = emitter
> v = 0.25

## 2. Zug mit Lichtblitzen an beiden Enden

In diesem Bezugssystem ($v = 0.25$) habe ich platziert:

* Einen **Zug** von $x = -0.25$ bis $x = 0.25$, zentriert bei $x = 0.0$.

* Zwei nach innen gerichtete Lichtblitze (in Orange), die am hinteren (**B**)
  und vorderen (**F**) Ende des Zuges bei $t = 0.0$ ausgesendet werden.

> setup: v=0.25, t=0.0, mode=emitter, tool=select
> object: train(name="Train", x=-0.25, t=0.0, v=0.25, color=purple)
> object: cone(name="B", x=-0.25, t=0.0, v=0.25, z=0.15, color=orange)
> object: cone(name="F", x=0.25, t=0.0, v=0.25, z=0.15, color=orange)

Bewegen Sie den **Zeit**-Schieberegler auf $t = 0.25$.

Beachten Sie, dass sich beide Lichtblitze in diesem Bezugssystem mit
Geschwindigkeit 1 bewegen und sich in der Mitte des Zuges treffen.

> t = 0.25

## 3. Emitter: Ansicht vom Boden

Wechseln Sie in das Ruhesystem des Bodens ($v = 0.0$) und gehen Sie zurück zu
$t = 0.0$.

Die Steigung der Lichtblitze ist nun unterschiedlich.

> v = 0.0
> t = 0.0

## 4. Emitter: Zeit vorrücken

Bewegen Sie den **Zeit**-Schieberegler auf $t = 0.5$.

Die Blitze treffen sich immer noch bei $t = 0.5$, aber nicht in der Mitte
zwischen den Flaggen, weil ein Blitz schneller ist als der andere.

> t = 0.5

## 5. Äther: Ansicht vom Boden

Gehen Sie zurück zu $t = 0.0$ und wählen Sie **Äther-Hypothese verwenden**.

> t = 0.0
> mode = ether

## 6. Äther: Blitze treffen sich in der Mitte

Bewegen Sie den **Zeit**-Schieberegler auf $t = 0.25$.

Die Blitze treffen sich in der Mitte der beiden Flaggen, weil die
Lichtgeschwindigkeit im Ruhesystem der Flaggen in beide Richtungen gleich ist.

> t = 0.25

## 7. Äther: Ansicht vom Zug

Gehen Sie zurück zu $t = 0.0$ und wechseln Sie in das Zugsystem ($v = 0.25$).

> t = 0.0
> v = 0.25

## 8. Äther: Blitze verfehlen die Zugmitte

Bewegen Sie den **Zeit**-Schieberegler auf $t = 0.25$.

Die Blitze treffen sich nicht in der Mitte des Zuges, weil sie im Zugsystem
unterschiedliche Geschwindigkeiten haben.

> t = 0.25

## 9. Äther: Warum die Strahlen die Mitte verfehlen

Im **Äthermodell** breitet sich Licht mit $c = 1$ relativ zum ruhenden
Bodenäther aus, nicht zum fahrenden Zug.

Weil der Zug sich mit $v = 0.25$ vorwärtsbewegt:

* eilt der vordere Strahl (**F**) mit $1 + 0.25 = 1.25$ auf die Mitte zu und
  erreicht sie frühzeitig ($t = 0.20$).

* holt der hintere Strahl (**B**) mit $1 - 0.25 = 0.75$ verspätet auf ($t =
  0.33$).

Unter derÄthertheorie treffen die Blitze *nicht* in der Zugmitte aufeinander!

Klicken Sie auf **Weiter**, um die experimentellen Ergebnisse zu erfahren.

> ok

## 10. Experimentelle Ergebnisse

Experimente zeigten, dass die Lichtgeschwindigkeit in allen Inertialsystemen
exakt gleich ist–unabhängig davon, ob die Quelle ruht oder sich bewegt!

Starten Sie das nächste Tutorial, um die Konsequenzen dieser Entdeckung zu
sehen.

> ok
