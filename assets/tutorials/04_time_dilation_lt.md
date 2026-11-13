# 4. Laiko sulėtėjimas ir judantys laikrodžiai

Sužinokite, kodėl judantis laikrodis tiksi lėčiau nei ramybės būsenoje esantis
laikrodis.

## 1. Alisos šviesos laikrodis

Patalpinome **Alisą** (su laikrodžiu ties $x = 0.0$) ir **Veidrodį** ties $x =
0.4$.Įvykyje **P1** $(0.0, 0.0)$ Alisa paleidžiašviesos spindulį, kuris
atsispindi ties **P2** $(0.4, 0.4)$ ir grįžta ties **P3** $(0.0, 0.8)$.

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

## 2. Patikrinkite Alisos laikrodį ties P3

Pastumkite **Laiką** iki $t = 0.8$ (įvykis **P3**). Alisos laikrodis rodo $t =
0.80$ ($0.4 + 0.4 = 0.8$).

> t = 0.8

## 3. Pereikite į Beno judančią sistemą

Pažvelkime iš**Beno**, judančio $v = -0.60$ greičiu ($\gamma = 1.25$),
sistemos. Nustatykite **Greitį**į$v = -0.60$.

> object: clock(name="Ben", x=0.0, t=0.0, v=-0.6, color=purple)
> v = -0.6

## 4. Šviesos kelionės laikas Benui

Kadangi veidrodis tolsta, pirmyn spindulys keliauja $t = 0.80$. Atgal Alisa
artėja, tad grįžimas trunka vos $0.20$ laiko vieneto. Pastumkite laikąiki $t =
1.0$.

> t = 1.0

## 5. Laikrodžių palyginimas

Ties **P3** ($t = 1.0$ Benui):

* **Beno laikrodis** rodo $t = 1.00$.

* **Alisos laikrodis** ties **P3** vis dar rodo $t = 0.80$!

Benas daro išvadą, kad Alisos judantis laikrodis vėluoja $\gamma = 1.25$
karto.

> ok

## 6. Momentų žymėjimas Beno sistemoje

Pridėjome du **Momentus**: **I1** ties $t = 0.0$ ir **I2** ties $t = 1.0$.
GrįžkiteįAlisos sistemą($v = 0.00$).

> object: instant(name="I1", x=0.0, t=0.0, v=-0.6, color=red)
> object: instant(name="I2", x=0.0, t=0.8, v=-0.6, color=purple)
> v = 0.0

## 7. Vienalaikiškumas išsprendžia paradoksą

Alisos sistemoje **I1** ir **I2** nebėra horizontalūs! Ties $t = 0.80$ Alisos
sistemoje Beno laikrodis terodo $0.64$. Kiekvienas stebėtojas mato kito
laikrodįeinant lėčiau dėl skirtingai pasvirusiųvienalaikiškumo plokštumų.

> ok
