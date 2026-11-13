# 4. Dilatação Temporal e Relógios em Movimento

Descubra por que um relógio em movimento bate mais devagar do que um relógio
em repouso.

## 1. O Relógio de Luz de Alice

Posicionamos **Alice** (com relógio em $x = 0.0$) e um **Espelho** em $x =
0.4$. Em **P1** $(0.0, 0.0)$, Alice emite um pulso de luz, que reflete no
espelho em **P2** $(0.4, 0.4)$ e retorna em **P3** $(0.0, 0.8)$.

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

## 2. Verificar o Relógio de Alice em P3

Avance o **Tempo** para $t = 0.8$ (evento **P3**). O relógio de Alice marca $t
= 0.80$ ($0.4 + 0.4 = 0.8$).

> t = 0.8

## 3. Mudar para o Referencial em Movimento de Ben

Vejamos pela perspectiva de **Ben**, que se desloca com velocidade $v = -0.60$
($\gamma = 1.25$). Ajuste a **Velocidade** para $v = -0.60$.

> object: clock(name="Ben", x=0.0, t=0.0, v=-0.6, color=purple)
> v = -0.6

## 4. Tempo de Percurso da Luz para Ben

Como o espelho se afasta do feixe de luz, a ida leva $t = 0.80$. Na volta,
Alice vai ao encontro do feixe, demorando apenas $0.20$. Avance o tempo para
$t = 1.0$.

> t = 1.0

## 5. Comparação dos Relógios

No evento **P3** ($t = 1.0$ no referencial de Ben):

* O **relógio de Ben** marca $t = 1.00$.

* O **relógio de Alice** em **P3** ainda marca $t = 0.80$!

Ben conclui que o relógio em movimento de Alice funciona com atraso por um
fator de $\gamma = 1.25$.

> ok

## 6. Marcando Instantes no Referencial de Ben

Adicionamos dois **Instantes**: **I1** em $t = 0.0$ e **I2** em $t = 1.0$.
Retorne ao referencial de Alice ($v = 0.00$).

> object: instant(name="I1", x=0.0, t=0.0, v=-0.6, color=red)
> object: instant(name="I2", x=0.0, t=0.8, v=-0.6, color=purple)
> v = 0.0

## 7. A Simultaneidade Resolve o Paradoxo

No referencial de Alice, **I1** e **I2** não são mais horizontais! Em $t =
0.80$ para Alice, o relógio de Ben marca apenas $0.64$. Cada observador vêo
relógio do outro andar mais devagar devidoàinclinação dos planos de
simultaneidade.

> ok
