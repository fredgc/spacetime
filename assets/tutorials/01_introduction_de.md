# 1. Einführung: Verwendung des Spacetime-Werkzeugs

Lernen Sie, wie Sie Minkowski-Raumzeit-Diagramme zeichnen, Objekte bearbeiten
und Bezugssysteme erkunden.

## 1. Was die Anzeige darstellt

Willkommen beim relativistischen Spacetime-Zeichenwerkzeug! Der Bildschirm ist
in zwei Ansichten unterteilt:

* **Raumzeitdiagramm (oben)**: Der Raum ($x$) liegt auf der horizontalen Achse
  und die Zeit ($t$) auf der vertikalen Achse, in Einheiten, in denen die
  Lichtgeschwindigkeit $c = 1$ ist.

* **Beobachteransicht (unten)**: Zeigt eine 1D-Animationsansicht dessen, was
  der Beobachter im aktuellen Moment $t$ sieht (markiert durch den
  horizontalen Balken im Raumzeitdiagramm).

Klicken Sie auf **Weiter**, um Objekte im Diagramm zu platzieren.

> reset
> setup: v=0.0, t=0.0, mode=lorentz
> ok

## 2. Ein Ereignis hinzufügen

Mit der Symbolleisteüber dem Diagramm können Sie zwischen **Auswählen** und
**Hinzufügen** wechseln und den Objekttyp festlegen.

Wechseln Sie zu **Hinzufügen**, wählen Sie **Ereignis** und klicken Sie auf
das blinkende Ziel auf der Raumzeitleinwand bei $(x = 0.0, t = 0.5)$ (oder
klicken Sie auf **Für mich ausführen**).

> add = event(x=0.0, t=0.5)

## 3. Weltlinien, Lichtkegel und Momente

Zusätzlich zu einzelnen Ereignissen können Sie zeichnen:

* **Positionen (Person, Zug, Scheune, Flagge, Uhr)**: Linien, die Objekte
  darstellen, die sich durch die Zeit bewegen (Weltlinien).

* **Lichtkegel**: Zwei Lichtstrahlen, die sich mit der Steigung $\pm 1$ nach
  links und rechts ausbreiten (da $c = 1$).

* **Moment**: Eine Linie aller Ereignisse, die für einen Beobachter zur selben
  Zeit stattfinden.

Wählen Sie bei aktivem **Hinzufügen** den **Lichtkegel** aus und klicken Sie
auf den Ursprung $(x = 0.0, t = 0.0)$, um einen Lichtblitz hinzuzufügen.

> add = cone(x=0.0, t=0.0)

## 4. Objekte auswählen

Um ein vorhandenes Objekt zu prüfen oder zu bearbeiten, wechseln Sie zu
**Auswählen** und klicken Sie auf das Objekt im Diagramm. (Durch Klicken und
Ziehen auf freier Fläche verschieben Sie den sichtbaren Bereich.)

Wir haben eine Person namens **Alice** bei $x = -0.5$ hinzugefügt. Wechseln
Sie zu **Auswählen** und klicken Sie auf Alices Weltlinie, um sie auszuwählen.

> object: person(name="Alice", x=-0.5, t=0.0, v=0.0, color=blue)
> select = Alice

## 5. Objekte verschieben und bearbeiten

Wenn ein Objekt ausgewählt ist, können Sie seinen Namen oder seine Farbe in
der oberen Symbolleisteändern, es löschen oder an eine neue Position ziehen.

Ziehen Sie **Alice** nach rechts auf $x = 0.5$ (oder klicken Sie auf **Für
mich ausführen**).

> move = Alice(x=0.5, tol=0.25)

## 6. Zeit animieren

Unterhalb der Beobachteransicht befindet sich der **Zeit**-Schieberegler, der
den aktuellen Zeitschnitt $t$ nach oben und unten bewegt.

Wir haben einen stehenden **Zug** bei $x = -0.25$ platziert und **Alice** mit
der Geschwindigkeit $v = 0.5$ nach rechts fahren lassen. Bewegen Sie den
**Zeit**-Schieberegler auf $t = 0.5$ und beobachten Sie die Ansicht, während
sich die Lichtstrahlen ausbreiten, das Ereignis aufblitzt und Alice den Zug
passiert!

> reset
> setup: v=0.0, t=0.0, mode=lorentz, tool=select
> object: event(name="E1", x=0.0, t=0.5, color=red)
> object: cone(name="L1", x=0.0, t=0.0, color=orange)
> object: train(name="Train", x=-0.25, t=0.0, v=0.0, color=green)
> object: person(name="Alice", x=0.0, t=0.0, v=0.5, color=blue)
> t = 0.5

## 7. Beobachtergeschwindigkeit ändern

Unterhalb des Zeitschiebereglers befindet sich der
**Geschwindigkeit**-Schieberegler. Er steuert die Geschwindigkeit $v$ unseres
Bezugssystems. Jedes neu hinzugefügte Objektübernimmt automatisch die aktuelle
Beobachtergeschwindigkeit.

Bewegen Sie den **Geschwindigkeit**-Schieberegler auf $v = 0.50$, um in Alices
Bezugssystem zu wechseln.

> v = 0.5

## 8. Relativität der Bewegung

In Alices Bezugssystem ($v = 0.50$) verläuft ihre Weltlinie senkrecht–sie
steht still–, während die Weltlinie des Zuges nach links geneigt ist!

Da die Gesetze der Physik relativ sind, ist die Aussage, dass der Zug an Alice
vorbeifährt, genauso gültig wie die Aussage bei $v = 0.0$, dass Alice am Zug
vorbeifährt.

Klicken Sie auf **Weiter**, um die Einführung abzuschließen!

> ok
