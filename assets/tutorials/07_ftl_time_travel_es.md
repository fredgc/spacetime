# 7. Más rápido que la luz y viajes en el tiempo

Descubra por quéel envío de un mensaje instantáneo o más rápido que la luz en
la relatividad especial le permite enviar un mensaje hacia el pasado a su
propia línea temporal.

## 1. Un mensaje instantáneo (A1 a A2)

Supongamos que tuviéramos un dispositivo capaz de enviar un mensaje
*instantáneo* (más rápido que la luz) en nuestro propio sistema de referencia.

Aquíhay dos observadores estacionarios, **A1** ($x = -0.5$) y **A2** ($x =
0.5$):

* **P1** $(-0.5, 0.5)$: **A1** redacta un mensaje.

* **P2** $(-0.5, 0.6)$: **A1** transmite el mensaje instantáneamente a lo
  largo del instante horizontal **MsgA** ($t = 0.6$).

* **P3** $(0.5, 0.6)$: **A2** recibe el mensaje en $t = 0.6$.

* **P4** $(0.5, 0.7)$: **A2** retransmite el mensaje a un viajero que pasa.

Haga clic en **Continuar**.

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

## 2. Cambiar a un sistema móvil

Ahora introduzcamos dos observadores en movimiento, **B1** y **B2**, que
viajan hacia la derecha a velocidad $v = 0.60$. **B1** pasa junto a **A1** en
el evento **P1**, y **B2** pasa junto a **A2** en el evento **P4**.

Ajuste el control de **Velocidad** a $v = 0.60$ para cambiar al sistema de
referencia de **B1** y **B2**.

> object: person(name="B1", x=-0.5, t=0.5, v=0.6, color=green)
> object: person(name="B2", x=0.5, t=0.7, v=0.6, color=green)
> v = 0.6

## 3. ¡P4 ocurre antes que P1!

Observe atentamente el orden temporal vertical de **P4** y **P1** en el
sistema $v = 0.60$:

* **P4** estáen $t = 0.50$.

* **P1** estáen $t = 1.00$.

En el sistema de **B1** y **B2**,¡**A2** le entrega el mensaje a **B2** en
**P4** *antes* de que **A1** siquiera redacte el mensaje en **P1**! Mueva el
control de **Tiempo** a $t = 0.70$ (a mitad de camino entre **P4** y **P1**).

> t = 0.7

## 4. B2 envía una respuesta instantánea a B1

En el tiempo $t = 0.70$ en el sistema $v = 0.60$ (evento **P5** en la línea de
universo de **B2**), **B2** utiliza un transmisor instantáneo idéntico para
enviar el mensaje a lo largo del instante **MsgB** a **B1**, quien lo recibe
de inmediato en el evento **P6** ($t = 0.70$).

Observe que **P6** estáen la línea de universo de **B1** *por debajo* (antes)
del evento **P1** ($t = 1.00$). Ahora vuelva a ajustar el control de
**Velocidad** a $v = 0.00$.

> object: event(name="P5", x=0.65, t=0.95, z=0.15, color=red)
> object: instant(name="MsgB", x=0.65, t=0.95, v=0.6, color=purple)
> object: event(name="P6", x=-0.725, t=0.125, color=red)
> v = 0.0

## 5. Un bucle temporal cerrado

Trace la cadena completa de eventos en el diagrama de espaciotiempo:

$$\text{P1} \rightarrow \text{P2} \rightarrow \text{P3} \rightarrow \text{P4} \rightarrow \text{P5} \rightarrow \text{P6} \rightarrow \text{P1}$$

Dado que **B1** recibe el mensaje en **P6** ($t = 0.125$) y se encuentra con
**A1** en **P1** ($t = 0.50$),¡**B1** puede entregarle el mensaje a **A1**
*antes* de que **A1** lo redacte en **P1**! Bajo la relatividad especial, las
señales más rápidas que la luz en cualquier sistema conducen inevitablemente a
paradojas causales hacia el pasado.

> ok
