# 6. Dvynių paradoksas

Sekite dvyniųporą, judančiąreliatyvistiniu greičiu, ir sužinokite, kodėl
keliavęs dvynys grįžta jaunesnis.

## 1. Išsiskyrimas ties e1

**Alisa** lieka vietoje ($v = 0.0$), o **Bobas** iškeliauja $v = 0.60$ greičiu
($\gamma = 1.25$). Jie startuoja kartu ties **e1** $(0.0, 0.0)$. Ties $0.40$
Bobo laikrodyje jis pasiekia posūkio tašką**e2** $(0.3, 0.5)$.

> reset
> setup: v=0.0, t=0.0, mode=lorentz, tool=select
> object: clock(name="Alice", x=0.0, t=0.0, v=0.0, z=0.05, color=blue)
> object: clock(name="Bob", x=0.0, t=0.0, v=0.6, z=0.2, color=green)
> object: event(name="e1", x=0.0, t=0.0, z=0.0, color=red)
> object: event(name="e2", x=0.3, t=0.5, z=0.0, color=red)
> ok

## 2. Grįžtančio dvynio Karolio pristatymas

Vietoj Bobo greitinimoįveskime trečiąstebėtoją–**Karolį**, judantįpriešinga
kryptimi greičiu $v = -0.60$. Nustatykite greitįį$v = -0.60$.

> v = -0.6

## 3. Karolio laikrodžio sinchronizavimas ties e2

Karolio linija kerta **e2** ir jo laikrodis suderinamas su Bobo laikrodžiu ($t
= 0.40$). Karolis susitinka su Alisa ties **e3** $(0.0, 1.0)$.

> object: clock(name="Carl", x=0.33, t=0.45, v=-0.6, z=0.15, color=purple)
> object: event(name="e3", x=0.0, t=1.0, z=0.0, color=red)
> ok

## 4. Grįžimas į Alisos sistemą

Nustatykite **Greitį**į$v = 0.00$.

> v = 0.0

## 5. Amžių palyginimas susitikus (e3)

Pastumkite **Laiką** iki $t = 1.0$:

* **Karolio laikrodis** rodo $t = 0.80$ ($0.40 + 0.40$).

* **Alisos laikrodis** rodo $t = 1.00$!

Keliavęs dvynys sugrįžta jaunesnis užAlisą.

> t = 1.0

## 6. Kodėl tai nėra simetriška?

Bobo sistemoje Alisos laikrodis eina lėčiau, tačiau Karolis Bobo atžvilgiu
juda dar greičiau ($v_{\text{rel}} \approx -0.88$), tad Karolio laikas eina
dar lėčiau. Be to, grįžimo etapas Bobo sistemoje trunka daug ilgiau nei
išvykimas.

> ok
