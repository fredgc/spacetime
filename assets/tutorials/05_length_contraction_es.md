# 5. Contracción de la longitud y la paradoja del tren y el granero

Explore cómo los objetos en movimiento se contraen a lo largo de su dirección
de movimiento y cómo la relatividad de la simultaneidad resuelve la clásica
paradoja del tren y el granero.

## 1. Distancia en un sistema en reposo

Hemos colocado a dos personas estacionarias, **A1** en $x = -1.0$ y **A2** en
$x = 1.0$. En su propio sistema de referencia ($v = 0.00$), la distancia entre
ellas es de $2.0$ unidades.

Haga clic en **Continuar** para ver quésucede con su separación al observarlas
desde un sistema en movimiento.

> reset
> setup: v=0.0, t=0.0, mode=lorentz, tool=select
> object: person(name="A1", x=-1.0, t=0.0, v=0.0, color=blue)
> object: person(name="A2", x=1.0, t=0.0, v=0.0, color=blue)
> ok

## 2. Contracción de la longitud a alta velocidad

Mueva el control de **Velocidad** a $v = 0.87$, donde el factor de escala de
Lorentz $\gamma = 1 / \sqrt{1 - v^2}$ es aproximadamente $2.0$.

Observe tanto en el diagrama de espaciotiempo como en la vista del observador
que **A1** y **A2** están ahora a solo unas $1.0$ unidades de distancia:¡la
mitad de su distancia en reposo!

> v = 0.87

## 3. Configuración del tren y el granero

Al igual que la dilatación del tiempo, la contracción de la longitud parece
crear una paradoja: si desde el granero se observa el tren más corto y desde
el tren se observa el granero más corto,¿cabe el tren dentro del granero?

Aquíhay un **Granero** estacionario ($v = 0.0$, ancho $0.50$, desde $x =
-0.25$ hasta $0.25$) y un **Tren** en movimiento ($v = 0.60$, ancho en reposo
$0.50$). Ajuste el control de **Velocidad** a $v = 0.00$ para ver el sistema
en reposo del granero.

> reset
> setup: v=0.87, t=0.0, mode=lorentz, tool=select
> object: barn(name="Barn", x=-0.25, t=0.0, v=0.0, color=green)
> object: train(name="Train", x=-0.20, t=0.0, v=0.6, color=orange)
> v = 0.0

## 4. Marcar el tren dentro del granero

En el sistema del granero ($v = 0.00$) en $t = 0.0$, el tren en movimiento se
contrae en $\sqrt{1 - 0.6^2} = 0.8$ hasta un ancho de $0.40$ (desde $x =
-0.20$ hasta $0.20$),¡por lo que cabe completamente dentro del granero!

Colocamos un evento rojo **B** en $(-0.20, 0.0)$ donde la parte trasera del
tren estádentro de la puerta izquierda. Añada un **Evento** en $(x = 0.2, t =
0.0)$ para marcar la parte frontal del tren dentro de la puerta derecha.

> object: event(name="B", x=-0.20, t=0.0, color=red)
> add = event(x=0.2, t=0.0)

## 5. Cambiar al sistema del tren

Ahora ajuste el control de **Velocidad** a $v = 0.60$ para mirar desde el
sistema de referencia del tren.

En este sistema, el tren tiene su ancho completo ($0.50$) mientras que el
granero se contrae a $0.40$:¡el tren es *más largo* que el granero!¿Quéocurrió
con nuestros dos eventos **B** (rojo) y **F** (azul)?

> reset
> setup: v=0.0, t=0.0, mode=lorentz, tool=select
> object: barn(name="Barn", x=-0.25, t=0.0, v=0.0, color=green)
> object: train(name="Train", x=-0.20, t=0.0, v=0.6, color=orange)
> object: event(name="B", x=-0.20, t=0.0, color=red)
> object: event(name="F", x=0.20, t=0.0, color=blue)
> v = 0.6

## 6. F alcanza la salida primero

En el sistema del tren ($v = 0.60$), **F** y **B** *no* ocurren al mismo
tiempo.

Mueva el control de **Tiempo** a $t = -0.15$ (cuando ocurre **F**). Mire la
vista del observador: la parte delantera del tren estáen el extremo derecho
del granero, mientras que la parte trasera todavía estáafuera hacia la
izquierda.

> t = -0.15

## 7. B entra más tarde

Ahora mueva el control de **Tiempo** hacia adelante hasta $t = 0.15$ (cuando
ocurre **B**).

Para cuando la parte trasera del tren estádentro de la puerta izquierda del
granero, la parte delantera ya ha pasado mucho más alláde la puerta derecha.
Ambos sistemas coinciden en los eventos **F** y **B**, pero solo ocurren
simultáneamente en el sistema del granero.

> t = 0.15
