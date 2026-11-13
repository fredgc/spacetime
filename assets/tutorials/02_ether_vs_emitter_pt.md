# 2. Velocidade da Luz Constante e Relatividade

O que significa a velocidade da luz ser constante?

## 1. Éter vs Velocidade do Emissor

Antes de Einstein, os cientistas descobriram que a velocidade da luz era
constante no vácuo. Mas constante em relação a quê?

Einstein começou com um experimento mental. Se estivermos em um trem, tomando
um café, partindo da Estação Central e emitirmos um feixe de luz, a velocidade
da luzérelativa ao solo ou relativa ao trem?

* **Teoria doÉter**: A luzéuma onda que se propaga em um meio estacionário
  universal (o "éter luminífero"). Sua velocidadeésempre $c = 1$ em relação ao
  éter, independentemente da velocidade da fonte.

* **Teoria do Emissor**: A luz consiste em partículas emitidas por uma fonteà
  velocidade $c = 1$ relativa ao emissor. Se o emissor viaja a $v$, o feixe
  frontal viaja a $c + v$ e o feixe traseiro a $c - v$.

Vamos testar ambas as teorias com um trem em movimento. Primeiro, testamos a
hipótese do emissor. Adicionei duas bandeiras no referencial $v = 0$.

Mude para **Usar Velocidade do Emissor** e defina a velocidade do observador
para $v = 0.25$.

> reset
> setup: v=0.0, t=0.0, mode=lorentz, tool=select
> object: flag(name="BF", x=-0.25, t=0.0, v=0.0, color=teal)
> object: flag(name="FF", x=0.25, t=0.0, v=0.0, color=teal)
> mode = emitter
> v = 0.25

## 2. Trem com Flashes em Ambas as Pontas

Neste referencial ($v = 0.25$), posicionei:

* Um **Trem** de $x = -0.25$ a $x = 0.25$, centrado em $x = 0.0$.

* Dois flashes de luz para dentro (em laranja) emitidos da traseira (**B**) e
  frente (**F**) do trem em $t = 0.0$.

> setup: v=0.25, t=0.0, mode=emitter, tool=select
> object: train(name="Train", x=-0.25, t=0.0, v=0.25, color=purple)
> object: cone(name="B", x=-0.25, t=0.0, v=0.25, z=0.15, color=orange)
> object: cone(name="F", x=0.25, t=0.0, v=0.25, z=0.15, color=orange)

Avance o **Tempo** para $t = 0.25$.

Ambos os flashes viajamàvelocidade 1 neste referencial e se encontram
exatamente no meio do trem.

> t = 0.25

## 3. Emissor: Visão a partir do Solo

Mude para o referencial do solo ($v = 0.0$) e retorne ao tempo $t = 0.0$.

A inclinação dos feixes de luzédiferente quando vista do solo.

> v = 0.0
> t = 0.0

## 4. Emissor: Avançar o Tempo

Avance o **Tempo** para $t = 0.5$.

Os dois flashes ainda se encontram em $t = 0.5$, mas não no ponto médio entre
as duas bandeiras, porque um flash foi mais rápido que o outro.

> t = 0.5

## 5. Éter: Visão a partir do Solo

Retorne a $t = 0.0$ e ative o modo **UsarÉter**.

> t = 0.0
> mode = ether

## 6. Éter: Flashes se encontram no meio

Avance o **Tempo** para $t = 0.25$.

Os flashes se encontram no meio das duas bandeiras, pois a velocidade da luzéa
mesma no referencial das bandeiras.

> t = 0.25

## 7. Éter: Visão a partir do Trem

Volte a $t = 0.0$ e mude para o referencial do trem ($v = 0.25$).

> t = 0.0
> v = 0.25

## 8. Éter: Flashes erram o meio do trem

Avance o **Tempo** para $t = 0.25$.

Os flashes não se encontram no meio do trem, porque suas velocidades diferem
em relação ao trem.

> t = 0.25

## 9. Éter: Por que erram o centro

No modelo doéter, a luz viaja a $c = 1$ em relação aoéter do solo, não ao
trem. Como o trem avança:

* O feixe frontal (**F**) corre contra o trem a $1 + 0.25 = 1.25$ e chega
  antes ($t = 0.20$).

* O feixe traseiro (**B**) persegue o centro a $1 - 0.25 = 0.75$ e chega
  depois ($t = 0.33$).

Clique em **Continuar** para conhecer os resultados experimentais.

> ok

## 10. Resultados Experimentais

Experimentos comprovaram que a velocidade da luzérigorosamente a mesma em
todos os referenciais, esteja a fonte em repouso ou em movimento!

Inicie o próximo tutorial para explorar as consequências dessa descoberta.

> ok
