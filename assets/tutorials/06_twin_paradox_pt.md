# 6. O Paradoxo dos Gêmeos

Acompanhe gêmeos que se separam em velocidade relativística e se reencontram
para entender por que o viajante retorna mais jovem.

## 1. Separação em e1

**Alice** permanece parada ($v = 0.0$) enquanto **Bob** parte a $v = 0.60$
($\gamma = 1.25$). Partem juntos de **e1** $(0.0, 0.0)$. Ao marcar $0.40$ em
seu relógio, Bob atinge o ponto de retorno **e2** $(0.3, 0.5)$.

> reset
> setup: v=0.0, t=0.0, mode=lorentz, tool=select
> object: clock(name="Alice", x=0.0, t=0.0, v=0.0, z=0.05, color=blue)
> object: clock(name="Bob", x=0.0, t=0.0, v=0.6, z=0.2, color=green)
> object: event(name="e1", x=0.0, t=0.0, z=0.0, color=red)
> object: event(name="e2", x=0.3, t=0.5, z=0.0, color=red)
> ok

## 2. Apresentando Carl no Retorno

Em vez de acelerar Bob, consideramos **Carl**, viajando no sentido oposto a $v
= -0.60$. Defina a **Velocidade** para $v = -0.60$.

> v = -0.6

## 3. Sincronização do Relógio de Carl em e2

A linha de Carl cruza **e2** e seu relógioéajustado para coincidir com o de
Bob ($0.40$). Carl reencontra Alice em **e3** $(0.0, 1.0)$.

> object: clock(name="Carl", x=0.33, t=0.45, v=-0.6, z=0.15, color=purple)
> object: event(name="e3", x=0.0, t=1.0, z=0.0, color=red)
> ok

## 4. Retornar ao Referencial de Alice

Defina a **Velocidade** como $v = 0.00$.

> v = 0.0

## 5. Comparando Idades no Reencontro (e3)

Avance o **Tempo** para $t = 1.0$:

* O **relógio de Carl** marca $t = 0.80$ ($0.40$ ida $+ 0.40$ volta).

* O **relógio de Alice** marca $t = 1.00$!

O gêmeo viajante retorna mais jovem que Alice.

> t = 1.0

## 6. Por que não é simétrico?

No referencial de Bob, o relógio de Alice anda mais devagar, mas Carl viaja em
relação a Bob com velocidade altíssima ($v_{\text{rel}} \approx -0.88$), de
modo que o relógio de Carl atrasa ainda mais. Além disso, a volta consome
muito mais tempo nesse referencial.

> ok
