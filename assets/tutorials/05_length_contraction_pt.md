# 5. Contração do Comprimento e o Paradoxo do Trem

Descubra como objetos em movimento se contraem na direção do deslocamento e
como a simultaneidade resolve o paradoxo do trem e do celeiro.

## 1. Distância no Referencial de Repouso

Duas pessoas, **A1** ($x = -1.0$) e **A2** ($x = 1.0$), estão separadas por
$2.0$ unidades em $v = 0.00$.

> reset
> setup: v=0.0, t=0.0, mode=lorentz, tool=select
> object: person(name="A1", x=-1.0, t=0.0, v=0.0, color=blue)
> object: person(name="A2", x=1.0, t=0.0, v=0.0, color=blue)
> ok

## 2. Contração em Alta Velocidade

Ajuste a **Velocidade** para $v = 0.87$ ($\gamma \approx 2.0$). A distância
encurta para metade: cerca de $1.0$ unidade!

> v = 0.87

## 3. O Trem e o Celeiro

Um **Celeiro** parado ($v = 0.0$, largura $0.50$) e um **Trem** em movimento
($v = 0.60$, comprimento de repouso $0.50$). Defina a velocidade para $v =
0.00$.

> reset
> setup: v=0.87, t=0.0, mode=lorentz, tool=select
> object: barn(name="Barn", x=-0.25, t=0.0, v=0.0, color=green)
> object: train(name="Train", x=-0.20, t=0.0, v=0.6, color=orange)
> v = 0.0

## 4. O Trem Dentro do Celeiro

No referencial do celeiro em $t = 0.0$, o trem contrai para $0.40$ ($x =
-0.20$ a $0.20$), cabendo totalmente dentro do celeiro! Adicione um **Evento**
em $(x = 0.2, t = 0.0)$.

> object: event(name="B", x=-0.20, t=0.0, color=red)
> add = event(x=0.2, t=0.0)

## 5. Mudar para o Referencial do Trem

Defina a **Velocidade** como $v = 0.60$. O trem mede $0.50$ e o celeiro
contrai para $0.40$—o tremémais longo que o celeiro!

> reset
> setup: v=0.0, t=0.0, mode=lorentz, tool=select
> object: barn(name="Barn", x=-0.25, t=0.0, v=0.0, color=green)
> object: train(name="Train", x=-0.20, t=0.0, v=0.6, color=orange)
> object: event(name="B", x=-0.20, t=0.0, color=red)
> object: event(name="F", x=0.20, t=0.0, color=blue)
> v = 0.6

## 6. A Frente Sai Primeiro

No referencial do trem, **F** e **B** não são simultâneos! Em $t = -0.15$
(**F**), a frente jáatinge a saída enquanto a traseira ainda estádo lado de
fora.

> t = -0.15

## 7. A Traseira Entra Depois

Em $t = 0.15$ (**B**), quando a traseira entra, a frente jásaiu hámuito tempo!
Os eventos são simultâneos somente no referencial do celeiro.

> t = 0.15
