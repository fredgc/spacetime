# 2. Velocidad de la luz constante y relatividad

¿Qué significa que la velocidad de la luz sea constante?

## 1. Éter frente a velocidad del emisor

Antes de Einstein, los científicos descubrieron que la velocidad de la luz era
constante en el vacío.¿Pero constante respecto a qué?

Einstein comenzócon un experimento mental. Si estamos en un tren, tomando
café, saliendo de la Estación de Atocha y emitimos un destello de luz,¿la
velocidad de la luz es relativa al suelo o relativa al tren?

* **Teoría deléter**: La luz es una onda que viaja a través de un medio
  universal estacionario (el "éter luminífero"). Su velocidad es siempre $c =
  1$ relativa aléter, independientemente de la velocidad de la fuente de luz.

* **Teoría del emisor**: La luz consiste en partículas emitidas por una fuente
  a velocidad $c = 1$ relativa al emisor. Si un emisor se mueve a velocidad
  $v$, su rayo frontal viaja a $c + v$ y su rayo trasero a $c - v$.

Probemos ambas teorías con un tren en movimiento. Analizaremos primero la
hipótesis del emisor. Hemos añadido dos banderas en el sistema $v = 0$. En el
siguiente paso añadiremos un tren en movimiento que pasa frente a estas
banderas.

Cambie a **Usar velocidad del emisor** y ajuste la velocidad del observador a
$v = 0.25$.

> reset
> setup: v=0.0, t=0.0, mode=lorentz, tool=select
> object: flag(name="BF", x=-0.25, t=0.0, v=0.0, color=teal)
> object: flag(name="FF", x=0.25, t=0.0, v=0.0, color=teal)
> mode = emitter
> v = 0.25

## 2. Tren con destellos en cada extremo

En este sistema de referencia ($v = 0.25$), he colocado:

* Un **Tren** que va desde $x = -0.25$ hasta $x = 0.25$, centrado en $x =
  0.0$.

* Dos destellos de luz hacia el interior (en naranja) emitidos desde la parte
  trasera (**B**) y delantera (**F**) del tren en $t = 0.0$.

> setup: v=0.25, t=0.0, mode=emitter, tool=select
> object: train(name="Train", x=-0.25, t=0.0, v=0.25, color=purple)
> object: cone(name="B", x=-0.25, t=0.0, v=0.25, z=0.15, color=orange)
> object: cone(name="F", x=0.25, t=0.0, v=0.25, z=0.15, color=orange)

Avance el control deslizante de **Tiempo** a $t = 0.25$.

Observe que los dos destellos de luz se mueven a velocidad 1 en este sistema y
se encuentran en el centro del tren.

> t = 0.25

## 3. Emisor: Vista desde el suelo

Cambie al sistema de referencia del suelo ($v = 0.0$) y vuelva al tiempo $t =
0.0$.

Observe que la pendiente de los destellos de luz es diferente.

> v = 0.0
> t = 0.0

## 4. Emisor: Avanzar el tiempo

Avance el control deslizante de **Tiempo** a $t = 0.5$.

Observe que los dos destellos de luz todavía se encuentran en $t = 0.5$, pero
no se encuentran en el punto medio de las dos banderas porque un destello es
más rápido que el otro.

> t = 0.5

## 5. Éter: Vista desde el suelo

Regrese a $t = 0.0$ y cambie al modo **Usaréter**.

> t = 0.0
> mode = ether

## 6. Éter: Los destellos se encuentran en el centro

Avance el control deslizante de **Tiempo** a $t = 0.25$.

Observe que los destellos de luz se encuentran en el punto medio entre las dos
banderas. Esto se debe a que la velocidad de la luz es idéntica en el sistema
de las banderas.

> t = 0.25

## 7. Éter: Vista desde el tren

Regrese a $t = 0.0$ y cambie al sistema de referencia del tren ($v = 0.25$).

Los destellos de luz comienzan en ambos extremos del tren.

> t = 0.0
> v = 0.25

## 8. Éter: Los destellos no alcanzan el centro del tren

Avance el control deslizante de **Tiempo** a $t = 0.25$.

Observe que los destellos no se encuentran en el centro del tren. Esto se debe
a que los dos destellos tienen velocidades diferentes en el sistema del tren.

> t = 0.25

## 9. Éter: Por qué no coinciden los rayos

En el modelo del **Éter**, la luz viaja a $c = 1$ relativa aléter estacionario
del suelo, no al tren en movimiento.

Debido a que el tren avanza a través deléter a $v = 0.25$:

* El rayo frontal (**F**) se dirige hacia el centro a una velocidad $1 + 0.25
  = 1.25$, llegando temprano al centro (en $t = 0.20$).

* El rayo trasero (**B**) intenta alcanzarlo a velocidad $1 - 0.25 = 0.75$,
  llegando tarde al centro (en $t = 0.33$).

Bajo la teoría deléter, los dos destellos *no* colisionan en el centro del
tren.

Haga clic en **Continuar** para conocer los resultados experimentales.

> ok

## 10. Resultados experimentales

Los experimentos demostraron que la velocidad de la luz era la misma en todos
los sistemas de referencia,¡incluso si el emisor estaba en movimiento o
estacionario!

Comience el siguiente tutorial para ver una consecuencia de que la velocidad
de la luz sea idéntica en todos los sistemas de referencia.

> ok
