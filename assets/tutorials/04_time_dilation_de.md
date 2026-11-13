# 4. Zeitdilatation & bewegte Uhren

Entdecken Sie, warum eine bewegte Uhr langsamer tickt als eine ruhende Uhr und
wie die Relativität der Gleichzeitigkeit das scheinbare Symmetrieparadoxon
auflöst.

## 1. Alices Lichtuhr

Wir haben **Alice** (mit einer Uhr bei $x = 0.0$) und einen **Spiegel**
(Flagge bei $x = 0.4$) platziert. Bei **P1** $(0.0, 0.0)$ sendet Alice einen
Lichtstrahl aus. Er reflektiert am Spiegel bei **P2** $(0.4, 0.4)$ und kehrt
bei **P3** $(0.0, 0.8)$ zu Alice zurück.

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

## 2. Alices Uhr bei P3 prüfen

Bewegen Sie den **Zeit**-Schieberegler auf $t = 0.8$ (Ereignis **P3**).

Alices Uhr zeigt $t = 0.80$ an. Der Spiegel ist $0.4$ Einheiten entfernt, die
Hin- und Rückreise dauert $0.4 + 0.4 = 0.8$ Zeiteinheiten.

> t = 0.8

## 3. Wechsel in Bens bewegtes System

Betrachten wir dies aus dem System von **Ben**, der sich mit $v = -0.60$
bewegt (Lorentz-Faktor $\gamma = 1.25$).

Setzen Sie die **Geschwindigkeit** auf $v = -0.60$.

> object: clock(name="Ben", x=0.0, t=0.0, v=-0.6, color=purple)
> v = -0.6

## 4. Lichtlaufzeit für Ben

Im Bens System ($v = -0.60$):

* Da der Spiegel dem Lichtstrahl davonfährt, dauert der Hinweg (**P1** bis
  **P2**) $t = 0.80$.

* Auf dem Rückweg (**P2** bis **P3**) bewegt sich Alice dem Strahl entgegen,
  was nur $0.20$ Einheiten dauert.

Bewegen Sie die **Zeit** auf $t = 1.0$, um Ereignis **P3** in Bens System zu
erreichen.

> t = 1.0

## 5. Bens und Alices Uhr vergleichen

Bei Ereignis **P3** ($t = 1.0$ in Bens System):

* **Bens Uhr** zeigt $t = 1.00$ ($0.80 + 0.20$).

* **Alices Uhr** zeigt bei **P3** immer noch $t = 0.80$!

Ben stellt fest, dass Alices bewegte Uhr um den Faktor $\gamma = 1.25$
verlangsamt geht.

> ok

## 6. Momente in Bens System markieren

Sieht Alice nicht auch Bens Uhr langsamer gehen? Wir haben zwei **Momente**
hinzugefügt:

* **I1** (rot) bei $t = 0.0$ (durch **P1**).

* **I2** (lila) bei $t = 1.0$ (durch **P3**, wenn Bens Uhr $1.00$ und Alices
  $0.80$ anzeigt).

Stellen Sie den Schieberegler wieder auf $v = 0.00$.

> object: instant(name="I1", x=0.0, t=0.0, v=-0.6, color=red)
> object: instant(name="I2", x=0.0, t=0.8, v=-0.6, color=purple)
> v = 0.0

## 7. Gleichzeitigkeit löst das Paradoxon auf

In Alices System ($v = 0.00$) sind **I1** und **I2** nicht mehr horizontal!

Ereignisse entlang **I2** finden für Alice nicht gleichzeitig statt. Bei $t =
0.80$ in Alices System zeigt Bens Uhr nur $0.64$! Beide Beobachter sehen die
Uhr des jeweils anderen langsamer laufen, weil sie entlang unterschiedlich
geneigter Gleichzeitigkeitsflächen messen.

> ok
