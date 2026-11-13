# 7. Überlichtgeschwindigkeit & Zeitreisen

Sehen Sie, warum eineüberlichtschnelle oder instantane Nachrichtenübertragung
in der speziellen Relativitätstheorie dazu führt, dass Nachrichten in die
eigene Vergangenheit gesendet werden können.

## 1. Eine instantane Nachricht (A1 an A2)

Zwei ruhende Beobachter: **A1** ($x = -0.5$) und **A2** ($x = 0.5$).

* **P1**: A1 verfasst eine Nachricht.

* **P2**: A1 sendet sie instanatan entlang **MsgA** ($t = 0.6$).

* **P3**: A2 empfängt sie bei $t = 0.6$.

* **P4**: A2übergibt sie an einen Reisenden.

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

## 2. Wechsel in ein bewegtes System

Zwei Beobachter, **B1** und **B2**, bewegen sich mit $v = 0.60$. Setzen Sie
die **Geschwindigkeit** auf $v = 0.60$.

> object: person(name="B1", x=-0.5, t=0.5, v=0.6, color=green)
> object: person(name="B2", x=0.5, t=0.7, v=0.6, color=green)
> v = 0.6

## 3. P4 geschieht vor P1!

Im bewegten System ist **P4** bei $t = 0.50$ und **P1** bei $t = 1.00$.

A2übergibt die Nachricht an B2 *bevor* A1 sieüberhaupt geschrieben hat! Setzen
Sie die Zeit auf $t = 0.70$.

> t = 0.7

## 4. B2 sendet instantane Antwort an B1

B2 sendet die Nachrichtüber **MsgB** an B1, der sie bei **P6** ($t = 0.70$)
empfängt.

Setzen Sie die **Geschwindigkeit** zurück auf $v = 0.00$.

> object: event(name="P5", x=0.65, t=0.95, z=0.15, color=red)
> object: instant(name="MsgB", x=0.65, t=0.95, v=0.6, color=purple)
> object: event(name="P6", x=-0.725, t=0.125, color=red)
> v = 0.0

## 5. Eine geschlossene Zeitschleife

$$\text{P1} \rightarrow \text{P2} \rightarrow \text{P3} \rightarrow \text{P4} \rightarrow \text{P5} \rightarrow \text{P6} \rightarrow \text{P1}$$

B1 empfängt die Nachricht bei $t = 0.125$ und kann sie A1übergeben, *bevor* A1
sie bei $t = 0.50$ verfasst!Überlichtsignale führen unweigerlich zu
Kausalitätsparadoxa.

> ok
