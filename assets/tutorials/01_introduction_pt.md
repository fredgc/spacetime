# 1. Introdução: Usando a Ferramenta Spacetime

Aprenda a desenhar diagramas de espaço-tempo de Minkowski, editar objetos e
explorar referenciais.

## 1. O que há na tela

Bem-vindoàferramenta de desenho relativístico Spacetime! A telaédividida em
duas visões:

* **Diagrama de Espaço-Tempo (superior)**: O espaço ($x$) estáno eixo
  horizontal e o tempo ($t$) no eixo vertical, em unidades onde a velocidade
  da luzé$c = 1$.

* **Visão do Observador (inferior)**: Mostra uma animação 1D do que o
  observador vêno instante de tempo atual $t$ (marcado pela barra horizontal
  no diagrama).

Clique em **Continuar** para começar a posicionar objetos.

> reset
> setup: v=0.0, t=0.0, mode=lorentz
> ok

## 2. Adicionando um Evento

A barra de ferramentas superior permite alternar entre **Selecionar** e
**Adicionar**, e escolher o tipo de objeto a criar.

Mude a ferramenta para **Adicionar**, escolha **Evento** e clique no alvo
piscante no diagrama em $(x = 0.0, t = 0.5)$ (ou clique em **Fazer por mim**).

> add = event(x=0.0, t=0.5)

## 3. Linhas de Universo, Cones de Luz e Instantes

Além de eventos pontuais, vocêpode desenhar:

* **Posições (Pessoa, Trem, Celeiro, Bandeira, Relógio)**: Linhas
  representando objetos que se movem no tempo (linhas de universo).

* **Cone de Luz**: Dois raios de luz se expandindo para a esquerda e para a
  direita com inclinação $\pm 1$ (jáque $c = 1$).

* **Instante**: Uma linha contendo todos os eventos que ocorrem ao mesmo tempo
  para um determinado observador.

Com **Adicionar** ativo, escolha **Cone de Luz** e clique na origem $(x = 0.0,
t = 0.0)$ para emitir um pulso de luz.

> add = cone(x=0.0, t=0.0)

## 4. Selecionando Objetos

Para inspecionar ou modificar um objeto, mude para **Selecionar** e clique
nele no diagrama. (Arrastar no espaço vazio move a visualização.)

Adicionamos uma pessoa chamada **Alice** em $x = -0.5$. Mude para
**Selecionar** e clique na linha de universo de Alice.

> object: person(name="Alice", x=-0.5, t=0.0, v=0.0, color=blue)
> select = Alice

## 5. Movendo e Editando Objetos

Com um objeto selecionado, vocêpode alterar seu nome ou cor na barra superior,
excluí-lo ou arrastá-lo para uma nova posição.

Arraste **Alice** para a direita até$x = 0.5$ (ou clique em **Fazer por
mim**).

> move = Alice(x=0.5, tol=0.25)

## 6. Animando o Tempo

Abaixo da Visão do Observador fica o controle de **Tempo**, que move a fatia
de tempo atual $t$ para cima e para baixo no diagrama.

Colocamos um **Trem** parado em $x = -0.25$ e **Alice** se movendo para a
direita com velocidade $v = 0.5$. Mova o controle de **Tempo** para $t = 0.5$
e observe os raios se expandirem e Alice ultrapassar o trem!

> reset
> setup: v=0.0, t=0.0, mode=lorentz, tool=select
> object: event(name="E1", x=0.0, t=0.5, color=red)
> object: cone(name="L1", x=0.0, t=0.0, color=orange)
> object: train(name="Train", x=-0.25, t=0.0, v=0.0, color=green)
> object: person(name="Alice", x=0.0, t=0.0, v=0.5, color=blue)
> t = 0.5

## 7. Mudando a Velocidade do Observador

Abaixo do controle de tempo estáo controle de **Velocidade**. Ele define a
velocidade $v$ do nosso referencial. Objetos recém-adicionados adotam
automaticamente essa velocidade.

Mova a **Velocidade** para $v = 0.50$ para entrar no referencial de Alice.

> v = 0.5

## 8. Relatividade do Movimento

No referencial de Alice ($v = 0.50$), sua linha de universoévertical (ela está
parada) e a do trem inclina-se para a esquerda!

Como as leis da física são relativas, dizer que o trem se move passando por
Aliceétão válido quanto voltar a $v = 0.0$ e dizer que Alice se move passando
pelo trem.

Clique em **Continuar** para concluir a introdução!

> ok
