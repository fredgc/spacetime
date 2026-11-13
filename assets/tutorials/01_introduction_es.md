# 1. Introducción: Uso de la herramienta Spacetime

Aprenda a dibujar diagramas de espaciotiempo de Minkowski, editar objetos y
explorar sistemas de referencia.

## 1. Qué hay en la pantalla

¡Bienvenido a la herramienta de dibujo de espaciotiempo relativista! La
pantalla se divide en dos vistas:

* **Diagrama de espaciotiempo (arriba)**: El espacio ($x$) estáen el eje
  horizontal y el tiempo ($t$) en el eje vertical, en unidades donde la
  velocidad de la luz es $c = 1$.

* **Vista del observador (abajo)**: Muestra una sección de animación 1D de lo
  que el observador ve en el instante de tiempo actual $t$ (marcado por la
  barra horizontal en el diagrama de espaciotiempo).

Haga clic en **Continuar** para comenzar a colocar objetos en el diagrama.

> reset
> setup: v=0.0, t=0.0, mode=lorentz
> ok

## 2. Añadir un evento

La barra de herramientas sobre el diagrama le permite cambiar entre
**Seleccionar** y **Añadir**, y elegir quétipo de objeto crear.

Cambie la herramienta a **Añadir**, elija **Evento** y haga clic en el
objetivo parpadeante en el lienzo de espaciotiempo en $(x = 0.0, t = 0.5)$ (o
haga clic en **Hacerlo por mí**).

> add = event(x=0.0, t=0.5)

## 3. Líneas de universo, conos de luz e instantes

Además de eventos individuales, puede dibujar:

* **Ubicaciones (Persona, Tren, Granero, Bandera, Reloj)**: Líneas que
  representan objetos que se mueven a través del tiempo (líneas de universo).

* **Cono de luz**: Dos rayos de luz que se expanden a izquierda y derecha con
  pendiente $\pm 1$ (dado que $c = 1$).

* **Instante**: Una línea de todos los eventos que ocurren al mismo tiempo
  para un observador.

Con **Añadir** activo, elija **Cono de luz** y haga clic en el origen $(x =
0.0, t = 0.0)$ para añadir un destello de luz.

> add = cone(x=0.0, t=0.0)

## 4. Selección de objetos

Para inspeccionar o modificar un objeto existente, cambie la herramienta a
**Seleccionar** y haga clic en el objeto en el diagrama. (Si hace clic y
arrastra en el espacio vacío, desplazarála vista).

Hemos añadido una persona llamada **Alice** en $x = -0.5$. Cambie a
**Seleccionar** y haga clic en la línea de universo de Alice para
seleccionarla.

> object: person(name="Alice", x=-0.5, t=0.0, v=0.0, color=blue)
> select = Alice

## 5. Mover y editar objetos

Cuando un objeto estáseleccionado, puede cambiar su nombre o color en la barra
de herramientas superior, eliminarlo o arrastrarlo a una nueva posición en el
lienzo.

Arrastre a **Alice** hacia la derecha hasta $x = 0.5$ (o haga clic en
**Hacerlo por mí**).

> move = Alice(x=0.5, tol=0.25)

## 6. Animación del tiempo

Debajo de la vista del observador se encuentra el control deslizante de
**Tiempo**, que mueve el corte de tiempo actual $t$ hacia arriba y hacia abajo
en el diagrama de espaciotiempo.

Hemos colocado un **Tren** estacionario en $x = -0.25$ y puesto a **Alice** en
movimiento hacia la derecha a una velocidad $v = 0.5$. Mueva el control
deslizante de **Tiempo** a $t = 0.5$ y observe la vista del observador
mientras los rayos de luz se expanden, el evento parpadea y Alice pasa al
tren.

> reset
> setup: v=0.0, t=0.0, mode=lorentz, tool=select
> object: event(name="E1", x=0.0, t=0.5, color=red)
> object: cone(name="L1", x=0.0, t=0.0, color=orange)
> object: train(name="Train", x=-0.25, t=0.0, v=0.0, color=green)
> object: person(name="Alice", x=0.0, t=0.0, v=0.5, color=blue)
> t = 0.5

## 7. Cambiar la velocidad del observador

Debajo del control de tiempo se encuentra el control de **Velocidad**.
Controla la velocidad $v$ de nuestro sistema de referencia. Cualquier objeto
nuevo compartiráautomáticamente la velocidad del observador actual.

Mueva el control de **Velocidad** a $v = 0.50$ para pasar al sistema de
referencia de Alice.

> v = 0.5

## 8. Relatividad del movimiento

En el sistema de referencia de Alice ($v = 0.50$), la línea de universo de
Alice es vertical (ella estáquieta), mientras que la línea de universo del
tren se inclina hacia la izquierda.

Dado que las leyes de la física son relativas, es igualmente válido decir que
el tren pasa junto a Alice como regresar a $v = 0.0$ y decir que Alice pasa
junto al tren.

Haga clic en **Continuar** para finalizar la introducción.

> ok
