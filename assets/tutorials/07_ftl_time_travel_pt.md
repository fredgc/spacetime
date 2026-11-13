# 7. Sinais Superluminosos e Viagem no Tempo

Veja por que emitir um sinal mais rápido que a luz na relatividade especial
permite enviar mensagens para o próprio passado.

## 1. Mensagem Instantânea (de A1 para A2)

Dois observadores estacionários: **A1** ($x = -0.5$) e **A2** ($x = 0.5$).

* **P1**: A1 redige uma mensagem.

* **P2**: A1 envia instantaneamente via **MsgA** ($t = 0.6$).

* **P3**: A2 recebe em $t = 0.6$.

* **P4**: A2 entrega a um viajante.

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

## 2. Mudar para um Referencial em Movimento

Observadores **B1** e **B2** viajam a $v = 0.60$. Ajuste a **Velocidade** para
$v = 0.60$.

> object: person(name="B1", x=-0.5, t=0.5, v=0.6, color=green)
> object: person(name="B2", x=0.5, t=0.7, v=0.6, color=green)
> v = 0.6

## 3. P4 Ocorre Antes de P1!

No referencial em movimento, **P4** estáem $t = 0.50$ e **P1** em $t = 1.00$.
A2 entrega a mensagem a B2 *antes* que A1 a tenha redigido! Ajuste o tempo
para $t = 0.70$.

> t = 0.7

## 4. B2 Envia Resposta Instantânea a B1

B2 envia via **MsgB** a B1, que a recebe em **P6** ($t = 0.70$). Ajuste a
**Velocidade** de volta para $v = 0.00$.

> object: event(name="P5", x=0.65, t=0.95, z=0.15, color=red)
> object: instant(name="MsgB", x=0.65, t=0.95, v=0.6, color=purple)
> object: event(name="P6", x=-0.725, t=0.125, color=red)
> v = 0.0

## 5. Um Ciclo Temporal Fechado

$$\text{P1} \rightarrow \text{P2} \rightarrow \text{P3} \rightarrow \text{P4} \rightarrow \text{P5} \rightarrow \text{P6} \rightarrow \text{P1}$$

B1 recebe a mensagem em $t = 0.125$ e pode entregá-la a A1 *antes* que A1 a
crie em $t = 0.50$! Sinais superluminais quebram a causalidade.

> ok
