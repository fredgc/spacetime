# 6. Das Zwillingsparadoxon

Begleiten Sie ein Zwillingspaar, das sich mit relativistischer Geschwindigkeit
trennt und wieder trifft, um zu verstehen, warum der reisende Zwilling jünger
zurückkehrt.

## 1. Trennung bei e1

**Alice** bleibt in Ruhe ($v = 0.0$), während **Bob** mit $v = 0.60$ ($\gamma
= 1.25$) davonreist.

Sie starten gemeinsam bei **e1** $(0.0, 0.0)$. Bei Uhrenstand $0.40$ erreicht
Bob den Umkehrpunkt **e2** $(0.3, 0.5)$.

> reset
> setup: v=0.0, t=0.0, mode=lorentz, tool=select
> object: clock(name="Alice", x=0.0, t=0.0, v=0.0, z=0.05, color=blue)
> object: clock(name="Bob", x=0.0, t=0.0, v=0.6, z=0.2, color=green)
> object: event(name="e1", x=0.0, t=0.0, z=0.0, color=red)
> object: event(name="e2", x=0.3, t=0.5, z=0.0, color=red)
> ok

## 2. Rückkehrender Zwilling Carl

Statt Bob zu beschleunigen, führen wir einen dritten Beobachter ein: **Carl**,
der sich mit $v = -0.60$ in Gegenrichtung bewegt.

Setzen Sie die **Geschwindigkeit** auf $v = -0.60$.

> v = -0.6

## 3. Carls Uhr bei e2 synchronisieren

Carls Weltlinie kreuzt **e2**, und seine Uhr wird auf Bobs Uhr abgeglichen
(beide zeigen $0.40$).

Carl trifft Alice bei **e3** $(0.0, 1.0)$ wieder.

> object: clock(name="Carl", x=0.33, t=0.45, v=-0.6, z=0.15, color=purple)
> object: event(name="e3", x=0.0, t=1.0, z=0.0, color=red)
> ok

## 4. Zurück in Alices Ruhesystem

Setzen Sie die **Geschwindigkeit** auf $v = 0.00$.

> v = 0.0

## 5. Alter beim Wiedersehen (e3)

Bewegen Sie die **Zeit** auf $t = 1.0$.

* **Carls Uhr** zeigt $t = 0.80$ ($0.40$ Hinreise $+ 0.40$ Rückreise).

* **Alices Uhr** zeigt $t = 1.00$!

Der reisende Zwilling ist bei seiner Rückkehr jünger als Alice.

> t = 1.0

## 6. Warum ist es nicht symmetrisch?

Im System von Bob ($v = 0.60$) vergeht die Zeit auf Alices Uhr tatsächlich
langsamer. Doch Carl bewegt sich relativ zu Bob mit $v_{\text{rel}} \approx
-0.88$, sodass Carl für Bob noch viel langsamer altert!

Zudem dauert der Rückweg im Bob-System viel länger als der Hinweg, sodass
Alices Uhr genug Zeit hat, Carls Uhr zuüberholen.

> ok
