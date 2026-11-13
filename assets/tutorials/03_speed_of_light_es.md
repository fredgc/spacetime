# 3. Velocidad de la luz constante y simultaneidad

Descubra por quéobservadores distintos discrepan sobre si dos eventos ocurren
al mismo tiempo, y cómo esta relatividad de la simultaneidad es la
consecuencia necesaria de una velocidad de la luz constante.

## 1. Tren con destello de luz central

Comencemos en el sistema de referencia de un tren que se mueve a $v = 0.25$.

Viajamos dentro del tren ($v = 0.25$). El tren morado va desde $x = -0.25$
hasta $x = 0.25$ (longitud en reposo $0.50$), centrado en $x = 0.0$.

Cambie a **Añadir**, elija **Cono de luz** y haga clic en la vista inferior
del observador (vista lateral) en el centro del tren $(x = 0.0, z = 0.15)$
para emitir un destello de luz dentro del tren (o haga clic en **Hacerlo por
mí**).

> reset
> setup: v=0.25, t=0.0, mode=lorentz, tool=add, type=cone
> object: train(name="Train", x=-0.25, t=0.0, v=0.25, color=purple)
> add = cone(name="Flash", x=0.0, t=0.0, z=0.15, color=orange, side=true)

## 2. Impactos simultáneos en el sistema del tren

Avance el control deslizante de **Tiempo** a $t = 0.25$.

En el sistema de referencia del tren, la luz se expande hacia afuera a
velocidad $c = 1$ en ambas direcciones. La parte trasera y delantera del tren
están a $0.25$ unidades del centro.

Mire la vista del observador abajo:¡los dos destellos impactan en ambos
extremos del tren en el mismo instante ($t = 0.25$)!

> t = 0.25

## 3. Cambiar al sistema del suelo

Ahora veamos esta escena desde el suelo. Mueva el control de **Velocidad** a
$v = 0.00$ y restablezca el control de **Tiempo** a $t = 0.00$.

Observe que bajo la relatividad especial (**Usar Lorentz**), la luz sigue
viajando a velocidad $c = 1$ (pendientes de $45^\circ$)¡a pesar de que el tren
se estámoviendo!

> v = 0.0
> t = 0.0

## 4. La luz alcanza la parte trasera del tren

Avance el control de **Tiempo** a $t = 0.19$.

En el sistema del suelo, el tren avanza hacia la derecha a $v = 0.25$. Su
parte trasera corre hacia el rayo de luz que viaja hacia atrás, encontrándolo
temprano en $t \approx 0.19$ (en $x \approx -0.19$).

Observe en la vista del observador que la luz ya alcanzóla parte trasera del
tren, mientras que el rayo frontal todavía persigue la parte delantera.

> t = 0.19

## 5. Marcar el evento B

Marquemos este evento en el espaciotiempo. Cambie a **Añadir**, elija
**Evento** y haga clic en la intersección en $(x = -0.19, t = 0.19)$ para
colocar el evento **B** (o haga clic en **Hacerlo por mí**).

> add = event(name="B", x=-0.19, t=0.19, color=red)

## 6. La luz alcanza la parte delantera del tren

Ahora avance el control de **Tiempo** a $t = 0.32$.

Como la parte delantera del tren se alejaba del destello de luz, el rayo
frontal tardómás en alcanzarla, chocando con ella en $t \approx 0.32$ (en $x
\approx 0.32$).

> t = 0.32

## 7. Marcar el evento F

Marque este segundo evento donde la luz alcanza el frente del tren. Haga clic
en la intersección en $(x = 0.32, t = 0.32)$ para colocar el evento **F** (o
haga clic en **Hacerlo por mí**).

> add = event(name="F", x=0.32, t=0.32, color=green)

## 8. Regresar al sistema del tren

Hemos etiquetado los dos eventos de impacto: **B** (rojo) y **F** (verde).

Ahora mueva el control de **Velocidad** del observador de vuelta a $v = 0.25$
para regresar al sistema en reposo del tren.

> reset
> setup: v=0.0, t=0.32, mode=lorentz, tool=select
> object: train(name="Train", x=-0.25, t=0.0, v=0.25, color=purple)
> object: cone(name="Flash", x=0.0, t=0.0, z=0.15, color=orange)
> object: event(name="B", x=-0.19, t=0.19, color=red)
> object: event(name="F", x=0.32, t=0.32, color=green)
> v = 0.25

## 9. ¡Simultáneos otra vez!

Ajuste el control de **Tiempo** a $t = 0.25$.

Observe el diagrama de espaciotiempo y la vista del observador: en el sistema
del tren ($v = 0.25$), tanto **B** como **F** ocurren exactamente al mismo
tiempo $t = 0.25$.

Intente alternar la **Velocidad** entre $v = 0.25$ y $v = 0.00$. Al cambiar de
sistema de referencia, la línea de simultaneidad se inclina:

* En el sistema del tren, los dos eventos son **simultáneos** ($t = 0.25$).

* En el sistema del suelo, **B** ocurre *primero* ($t = 0.19$) y **F** ocurre
  *segundo* ($t = 0.32$).

> t = 0.25

## 10. Relatividad de la simultaneidad

Si la luz tiene la misma velocidad en todos los sistemas de referencia bajo la
transformación de Lorentz, entonces el hecho de que dos eventos separados
ocurran al "mismo tiempo" depende del observador.

La simultaneidad absoluta no existe. Los observadores en movimiento relativo
discreparán sobre el orden temporal de eventos distantes.

Haga clic en **Continuar** para completar el tutorial.

> ok
