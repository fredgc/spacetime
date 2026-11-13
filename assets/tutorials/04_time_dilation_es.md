# 4. Dilatación del tiempo y relojes en movimiento

Descubra por quéun reloj en movimiento avanza más lentamente que un reloj
estacionario, y cómo la relatividad de la simultaneidad resuelve la aparente
paradoja de la simetría.

## 1. El reloj de luz de Alice

En la Lección 3 vimos que distintos observadores discrepan sobre quéeventos
ocurren al mismo tiempo. Ahora veamos por quétambién miden el paso del tiempo
a ritmos diferentes.

Hemos colocado a **Alice** (con un reloj en $x = 0.0$) y un **Espejo**
(bandera en $x = 0.4$). En el evento **P1** $(0.0, 0.0)$, Alice emite un pulso
de luz. Rebota en el espejo en **P2** $(0.4, 0.4)$ y regresa a Alice en **P3**
$(0.0, 0.8)$. Haga clic en **Continuar**.

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

## 2. Comprobar el reloj de Alice en P3

Mueva el control de **Tiempo** hacia adelante hasta $t = 0.8$ (evento **P3**).

En la vista del observador, observe que el reloj de Alice marca $t = 0.80$.
Esto tiene sentido: el espejo estáa $0.4$ unidades de distancia y la luz viaja
a velocidad $1$, por lo que el viaje de ida y vuelta toma $0.4 + 0.4 = 0.8$
unidades de tiempo.

> t = 0.8

## 3. Cambiar al sistema móvil de Ben

Ahora veamos exactamente estos mismos eventos desde el sistema de referencia
de **Ben**, un observador que se mueve a una velocidad $v = -0.60$ (donde el
factor de Lorentz es $\gamma = 1.25$).

Ajuste el control de **Velocidad** a $v = -0.60$.

> object: clock(name="Ben", x=0.0, t=0.0, v=-0.6, color=purple)
> v = -0.6

## 4. Tiempo de viaje de la luz para Ben

Mire el diagrama de espaciotiempo en el sistema de Ben ($v = -0.60$):

* Ambos rayos de luz todavía viajan a velocidad $1$ (pendientes de
  $45^\circ$).

* Debido a que el espejo se mueve hacia la derecha alejándose del rayo
  saliente, el primer tramo (**P1** a **P2**) recorre más distancia y toma $t
  = 0.80$.

* En el tramo de regreso (**P2** a **P3**), Alice se mueve hacia el rayo
  reflejado, por lo que solo toma $0.20$ unidades de tiempo.

Mueva el control de **Tiempo** a $t = 1.0$ para llegar al evento **P3** en el
sistema de Ben.

> t = 1.0

## 5. Comparar el reloj de Ben y el reloj de Alice

En el evento **P3** ($t = 1.0$ en el sistema de Ben), mire los dos relojes en
la vista del observador:

* El **reloj de Ben** marca $t = 1.00$ ($0.80 + 0.20$).

* ¡El **reloj de Alice** en **P3** todavía marca $t = 0.80$!

Ben concluye que el reloj en movimiento de Alice avanza más despacio por un
factor de $\gamma = 1.25$. Haga clic en **Continuar** para ver por quéesto no
provoca una contradicción.

> ok

## 6. Marcar instantes en el sistema de Ben

Por simetría,¿no debería Alice ver también el reloj de Ben avanzando más
lento? Para resolver esta paradoja, hemos añadido dos **Instantes**
horizontales en el sistema de referencia de Ben:

* **I1** (rojo) en $t = 0.0$ (pasando por **P1**, cuando ambos relojes marcan
  $0$).

* **I2** (morado) en $t = 1.0$ (pasando por **P3**, cuando el reloj de Ben
  marca $1.00$ y el de Alice marca $0.80$).

Ahora mueva el control de **Velocidad** de vuelta a $v = 0.00$ para regresar
al sistema de Alice.

> object: instant(name="I1", x=0.0, t=0.0, v=-0.6, color=red)
> object: instant(name="I2", x=0.0, t=0.8, v=-0.6, color=purple)
> v = 0.0

## 7. La simultaneidad resuelve la paradoja

En el sistema de referencia de Alice ($v = 0.00$),¡las líneas **I1** e **I2**
ya no son horizontales!

Los eventos a lo largo de **I2** *no* ocurren al mismo tiempo para Alice. En
$t = 0.80$ en el sistema de Alice (cuando Alice alcanza **P3**), Ben aún no ha
alcanzado **I2**; en el sistema de Alice, el reloj de Ben en $t = 0.80$ solo
marca $0.64$. Ambos observadores ven que el reloj del otro avanza más despacio
porque miden "al mismo tiempo" a lo largo de planos de simultaneidad
inclinados distintos.

> ok
