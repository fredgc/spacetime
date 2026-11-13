# 5. Längenkontraktion & das Scheunen-Paradoxon

Erfahren Sie, wie bewegte Objekte in Bewegungsrichtung schrumpfen und wie die
Relativität der Gleichzeitigkeit das klassische Zug-Scheunen-Paradoxon
auflöst.

## 1. Abstand im Ruhesystem

Wir haben zwei Personen platziert: **A1** bei $x = -1.0$ und **A2** bei $x =
1.0$. In ihrem Ruhesystem ($v = 0.00$) beträgt der Abstand $2.0$ Einheiten.

> reset
> setup: v=0.0, t=0.0, mode=lorentz, tool=select
> object: person(name="A1", x=-1.0, t=0.0, v=0.0, color=blue)
> object: person(name="A2", x=1.0, t=0.0, v=0.0, color=blue)
> ok

## 2. Längenkontraktion bei hoher Geschwindigkeit

Bewegen Sie den **Geschwindigkeit**-Schieberegler auf $v = 0.87$ (wo $\gamma
\approx 2.0$ ist).

Der Abstand zwischen **A1** und **A2** beträgt jetzt nur noch ca. $1.0$
Einheit–die Hälfte des Ruheabstands!

> v = 0.87

## 3. Zug und Scheune

Hier ist eine ruhende **Scheune** ($v = 0.0$, Breite $0.50$, $x = -0.25$ bis
$0.25$) und ein bewegter **Zug** ($v = 0.60$, Ruhebreite $0.50$). Setzen Sie
die **Geschwindigkeit** auf $v = 0.00$.

> reset
> setup: v=0.87, t=0.0, mode=lorentz, tool=select
> object: barn(name="Barn", x=-0.25, t=0.0, v=0.0, color=green)
> object: train(name="Train", x=-0.20, t=0.0, v=0.6, color=orange)
> v = 0.0

## 4. Den Zug in der Scheune markieren

Im Ruhesystem der Scheune ($v = 0.00$) ist der Zug bei $t = 0.0$ auf $0.40$
verkürzt (von $x = -0.20$ bis $0.20$). Er passt komplett in die Scheune!

Fügen Sie ein **Ereignis** bei $(x = 0.2, t = 0.0)$ hinzu, um die Zugspitze im
rechten Tor zu markieren.

> object: event(name="B", x=-0.20, t=0.0, color=red)
> add = event(x=0.2, t=0.0)

## 5. Wechsel ins Zugsystem

Setzen Sie die **Geschwindigkeit** auf $v = 0.60$.

In diesem System hat der Zug seine volle Länge ($0.50$), während die Scheune
auf $0.40$ kontrahiert ist–der Zug ist *länger* als die Scheune!

> reset
> setup: v=0.0, t=0.0, mode=lorentz, tool=select
> object: barn(name="Barn", x=-0.25, t=0.0, v=0.0, color=green)
> object: train(name="Train", x=-0.20, t=0.0, v=0.6, color=orange)
> object: event(name="B", x=-0.20, t=0.0, color=red)
> object: event(name="F", x=0.20, t=0.0, color=blue)
> v = 0.6

## 6. F erreicht das Tor zuerst

Im Zugsystem ($v = 0.60$) finden **F** und **B** nicht gleichzeitig statt!

Bewegen Sie die **Zeit** auf $t = -0.15$ (wenn **F** eintritt). Die Spitze ist
am Tor, das Heck noch weit außerhalb.

> t = -0.15

## 7. B tritt später ein

Bewegen Sie die **Zeit** vorwärts auf $t = 0.15$ (wenn **B** eintritt).

Wenn das Heck die Scheune betritt, ist die Spitze längst wieder draußen! Beide
Systeme stimmen in den Ereignissenüberein, aber sie finden nur im
Scheunensystem gleichzeitig statt.

> t = 0.15
