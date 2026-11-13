---
title: Barra de Herramientas y Deslizadores
---

Las barras superior e inferior de la aplicación contienen controles para
manipular y explorar el diagrama de espacio-tiempo:

## Menú

### Configuración

Al hacer clic en el icono de engranaje se abrirála página de configuración.
Las configuraciones se guardan localmente. Los colores están vinculados a la
configuración, no al dibujo.

### Archivo

Guarde o cargue archivos. Consulte [Gestión de Archivos](files.html) para
obtener ayuda.

### Menú Editar

Cortar y Pegar.

### Vista

Elija Lorentz,Éter o Emisor para la transformación de la velocidad de la luz.
Consulte [Transformaciones Relativistas](transformations.html) para más
información.

## Herramientas del Editor (Barra Superior)

* **Añadir/Seleccionar**: Toque este botón para alternar entre añadir o
  seleccionar un objeto.

  * **Seleccionar**: Permite seleccionar objetos en el Diagrama de
    Espacio-Tiempo o en la Vista Lateral para ver detalles, editar nombres o
    cambiar colores.

  * **Añadir**: Añade un objeto a la escena. Haga clic en la vista principal o
    en la vista lateral para añadir un objeto.

* **Nombre**: El nombre del objeto seleccionado o del objeto que se añadirá.
  Toque el texto para cambiar el nombre.

* **Tipo**: El tipo del objeto seleccionado o del objeto que se añadirá.

  * **Evento**. Unúnico punto en el tiempo y el espacio.

  * **Instante**. Un instante en el tiempo, relativo al observador actual. Es
    una línea horizontal cuando no se utiliza la transformación de Lorentz.

  * **Cono de Luz**. Un par de rayos de luz que se mueven a izquierda y
    derecha. La velocidad de la luz es $c = 1.0$.

  * **Ubicación (Reloj/Persona/Tren/Granero/Bandera)**: Una ubicaciónúnica,
    relativa al observador actual.

* **Color**: El color del objeto seleccionado o del objeto que se añadirá.

## Deslizadores (Barra Inferior)

* **Deslizador de Tiempo ($t$)**: Mueve el tiempo del observador actual hacia
  adelante y hacia atrás. Ajustar este control anima la posición de las
  ubicaciones y el estado de eventos/relojes en la Vista Lateral. Presione la
  flecha a la derecha para iniciar la animación hacia adelante. La flecha a la
  izquierda anima hacia atrás.

* **Deslizador de Velocidad ($v$)**: Cambia la velocidad relativa del marco
  del observador. Modificar la velocidad recalcula y transforma
  instantáneamente las posiciones de todos los objetos en ambos diagramas
  según el modelo de transformación seleccionado.
