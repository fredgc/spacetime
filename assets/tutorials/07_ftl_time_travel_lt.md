# 7. Virššviesiniai signalai ir kelionės laiku

Sužinokite, kodėl virššviesinio ar momentinio pranešimo siuntimas
specialiojoje reliatyvumo teorijoje leidžia nusiųstižinutęįsavo paties
praeitį.

## 1. Momentinis pranešimas (nuo A1 iki A2)

Du nejudantys stebėtojai: **A1** ($x = -0.5$) ir **A2** ($x = 0.5$).

* **P1**: A1 parašožinutę.

* **P2**: A1 išsiunčia jąmomentaliai per **MsgA** ($t = 0.6$).

* **P3**: A2 jągauna ties $t = 0.6$.

* **P4**: A2 perduoda jąkeliautojui.

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

## 2. Perėjimas į judančią sistemą

Du stebėtojai, **B1** ir **B2**, juda greičiu $v = 0.60$. Nustatykite greitįį
$v = 0.60$.

> object: person(name="B1", x=-0.5, t=0.5, v=0.6, color=green)
> object: person(name="B2", x=0.5, t=0.7, v=0.6, color=green)
> v = 0.6

## 3. P4 įvyksta prieš P1!

Judančioje sistemoje **P4** yra ties $t = 0.50$, o **P1**–ties $t = 1.00$. A2
perduodažinutęB2 *prieš* A1 jąparašant! Pastumkite laikąiki $t = 0.70$.

> t = 0.7

## 4. B2 siunčia momentinį atsakymą į B1

B2 siunčiažinutęper **MsgB**įB1, kuris jągauna ties **P6** ($t = 0.70$).
Grąžinkite greitį$v = 0.00$.

> object: event(name="P5", x=0.65, t=0.95, z=0.15, color=red)
> object: instant(name="MsgB", x=0.65, t=0.95, v=0.6, color=purple)
> object: event(name="P6", x=-0.725, t=0.125, color=red)
> v = 0.0

## 5. Uždara laiko kilpa

$$\text{P1} \rightarrow \text{P2} \rightarrow \text{P3} \rightarrow \text{P4} \rightarrow \text{P5} \rightarrow \text{P6} \rightarrow \text{P1}$$

B1 gaunažinutęties $t = 0.125$ ir gali jąįteikti A1 *prieš* A1 jąparašant ties
$t = 0.50$! Virššviesiniai signalai sukelia priežastingumo paradoksus.

> ok
