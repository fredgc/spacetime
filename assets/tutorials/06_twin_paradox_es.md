# 6. La paradoja de los gemelos

Siga a un par de gemelos que se separan a velocidad relativista y se reúnen
para descubrir por quéel gemelo viajero regresa más joven.

## 1. Los gemelos se separan en e1

Considere un par de gemelos: **Alice** se queda en reposo ($v = 0.0$),
mientras que **Bob** se aleja hacia la derecha a $v = 0.60$ ($\gamma = 1.25$).

Comienzan en el mismo lugar y momento en el evento **e1** $(0.0, 0.0)$, por lo
que ambos coinciden en que sus relojes marcan $0.00$ en **e1**. Cuando el
reloj de Bob marca $0.40$, alcanza el evento de retorno **e2** $(0.3, 0.5)$.
Haga clic en **Continuar**.

> reset
> setup: v=0.0, t=0.0, mode=lorentz, tool=select
> object: clock(name="Alice", x=0.0, t=0.0, v=0.0, z=0.05, color=blue)
> object: clock(name="Bob", x=0.0, t=0.0, v=0.6, z=0.2, color=green)
> object: event(name="e1", x=0.0, t=0.0, z=0.0, color=red)
> object: event(name="e2", x=0.3, t=0.5, z=0.0, color=red)
> ok

## 2. Presentar al gemelo que regresa, Carl

¿Quésucede cuando Bob da la vuelta en **e2** y regresa hacia Alice? En lugar
de acelerar a Bob, introduzcamos un tercer observador, **Carl**, que viaja en
la dirección opuesta a $v = -0.60$.

Ajuste el control de **Velocidad** a $v = -0.60$ (sistema de referencia de
Carl).

> v = -0.6

## 3. Sincronizar el reloj de Carl en e2

Hemos añadido a **Carl** ($v = -0.60$) de modo que su línea de universo pase
por el evento de retorno **e2** y su reloj coincida con el de Bob en **e2**
(ambos marcan $t = 0.40$ en **e2**).

La línea de universo de Carl continúa hacia la izquierda y se encuentra con
Alice nuevamente en el evento de reunión **e3** $(0.0, 1.0)$. Haga clic en
**Continuar** para regresar al sistema de Alice.

> object: clock(name="Carl", x=0.33, t=0.45, v=-0.6, z=0.15, color=purple)
> object: event(name="e3", x=0.0, t=1.0, z=0.0, color=red)
> ok

## 4. Regresar al sistema de referencia de Alice

Mueva el control de **Velocidad** a $v = 0.00$ para observar desde el sistema
en reposo de Alice.

> v = 0.0

## 5. Comparar edades en la reunión (e3)

Ahora mueva el control de **Tiempo** hacia adelante hasta $t = 1.0$ para ver
el evento de reunión **e3** donde Carl y Alice se encuentran.

Mire las lecturas de los relojes en la vista inferior del observador en $t =
1.0$:

* El **reloj de Carl** marca $t = 0.80$ ($0.40$ en la ida con el reloj de Bob
  más $0.40$ en el regreso con el reloj de Carl).

* ¡El **reloj de Alice** marca $t = 1.00$!

Cuando el gemelo viajero regresa, es más joven que Alice.

> t = 1.0

## 6. ¿Por qué no es simétrico?

¿Cambióde velocidad el reloj de Bob o el de Carl en algún momento? No: cada
uno marcóel tiempo a ritmo constante en su propio sistema inercial. Cambie al
sistema de Bob ajustando el control de **Velocidad** a $v = 0.60$.

> v = 0.6

## 7. La perspectiva de Bob

En el sistema de Bob ($v = 0.60$), el reloj de Alice *sí* avanza más despacio
que el de Bob. Sin embargo, Carl se mueve aún más rápido respecto a Bob
($v_{\text{rel}} \approx -0.88$),¡por lo que Bob ve el reloj de Carl avanzar
mucho más despacio que el de Alice!

Además, en el sistema de Bob el tramo de regreso (**e2** a **e3**) dura mucho
más tiempo que el tramo de ida (**e1** a **e2**), lo que le da al reloj de
Alice tiempo suficiente para adelantar al reloj de Carl antes de que se
encuentren en **e3**.

> ok
