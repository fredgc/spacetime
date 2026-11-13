# 3. Velocidade da Luz Constante e Simultaneidade

Descubra por que observadores em movimento discordam sobre se dois eventos
ocorrem ao mesmo tempo, e como essa relatividade da simultaneidadeé
consequência da velocidade da luz constante.

## 1. Trem com Flash Central

Comecemos no referencial de um trem viajando a $v = 0.25$.

O trem roxo vai de $x = -0.25$ a $x = 0.25$ (comprimento de repouso $0.50$).
Escolha **Adicionar**, selecione **Cone de Luz** e clique no centro do trem
$(x = 0.0, z = 0.15)$ na visão inferior para emitir um pulso.

> reset
> setup: v=0.25, t=0.0, mode=lorentz, tool=add, type=cone
> object: train(name="Train", x=-0.25, t=0.0, v=0.25, color=purple)
> add = cone(name="Flash", x=0.0, t=0.0, z=0.15, color=orange, side=true)

## 2. Impactos Simultâneos no Trem

Avance o **Tempo** para $t = 0.25$.

No referencial do trem, a luz se expande a $c = 1$ em ambas as direções. Os
dois feixes atingem as duas extremidades no exato mesmo instante ($t = 0.25$)!

> t = 0.25

## 3. Mudar para o Referencial do Solo

Defina a **Velocidade** como $v = 0.00$ e o **Tempo** como $t = 0.00$. Na
relatividade especial (**Lorentz**), a luz viaja sempre a $c = 1$ (inclinações
de $45^\circ$) mesmo com o trem em movimento!

> v = 0.0
> t = 0.0

## 4. Luz atinge a Traseira do Trem

Avance o **Tempo** para $t = 0.19$. A traseira do trem vai ao encontro do
feixe de luz que viaja para trás, encontrando-o antes, em $t \approx 0.19$.

> t = 0.19

## 5. Marcar Evento B

Mude para **Adicionar**, escolha **Evento** e marque o evento **B** em $(x =
-0.19, t = 0.19)$.

> add = event(name="B", x=-0.19, t=0.19, color=red)

## 6. Luz atinge a Frente do Trem

Avance o **Tempo** para $t = 0.32$. Como a frente se afastava do ponto de
emissão, o feixe demora mais para alcançá-la, atingindo-a em $t \approx 0.32$.

> t = 0.32

## 7. Marcar Evento F

Marque o evento **F** em $(x = 0.32, t = 0.32)$.

> add = event(name="F", x=0.32, t=0.32, color=green)

## 8. Retornar ao Referencial do Trem

Ajuste a **Velocidade** de volta para $v = 0.25$.

> reset
> setup: v=0.0, t=0.32, mode=lorentz, tool=select
> object: train(name="Train", x=-0.25, t=0.0, v=0.25, color=purple)
> object: cone(name="Flash", x=0.0, t=0.0, z=0.15, color=orange)
> object: event(name="B", x=-0.19, t=0.19, color=red)
> object: event(name="F", x=0.32, t=0.32, color=green)
> v = 0.25

## 9. Simultâneos Novamente!

Defina o **Tempo** em $t = 0.25$. No referencial do trem, ambos os eventos
**B** e **F** ocorrem no mesmo instante!

Ao mudar de referencial, a linha de simultaneidade inclina-se:

* No trem, os eventos são **simultâneos** ($t = 0.25$).

* No solo, **B** ocorre primeiro ($t = 0.19$) e **F** depois ($t = 0.32$).

> t = 0.25

## 10. Relatividade da Simultaneidade

Não existe simultaneidade absoluta. Observadores em movimento relativo
discordam sobre a ordem temporal de eventos espacialmente separados.

> ok
