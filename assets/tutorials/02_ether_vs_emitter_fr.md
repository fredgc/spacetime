# 2. Vitesse constante de la lumière et relativité

Que signifie le fait que la vitesse de la lumière soit constante ?

## 1. Éther vs vitesse de l'émetteur

Avant Einstein, les scientifiques ont découvert que la vitesse de la lumière
était constante dans le vide. Mais constante par rapportàquoi ?

Einstein a commencépar une expérience de pensée. Si nous sommesàbord d'un
train, buvant un café, quittant la gare de Lyon et que nousémettons un flash
lumineux, la vitesse de la lumière est-elle relative au sol ou au train ?

* **Théorie de l'éther** : La lumière est une onde se propageant dans un
  milieu universel immobile (l'«éther luminifère»). Sa vitesse est toujours $c
  = 1$ par rapportàl'éther, quelle que soit la vitesse de la source.

* **Théorie de l'émetteur** : La lumière est composée de particulesémises par
  une sourceàla vitesse $c = 1$ relativeàl'émetteur. Si la source avanceàla
  vitesse $v$, le rayon avant vaà$c + v$ et le rayon arrièreà$c - v$.

Testons les deux théories avec un train en mouvement. Nous examinerons d'abord
l'hypothèse de l'émetteur. J'ai ajoutédeux drapeaux dans le référentiel $v =
0$.

Basculez sur **Vitesse de l'émetteur** et réglez la vitesse de l'observateur
sur $v = 0.25$.

> reset
> setup: v=0.0, t=0.0, mode=lorentz, tool=select
> object: flag(name="BF", x=-0.25, t=0.0, v=0.0, color=teal)
> object: flag(name="FF", x=0.25, t=0.0, v=0.0, color=teal)
> mode = emitter
> v = 0.25

## 2. Train avec flashs à chaque extrémité

Dans ce référentiel ($v = 0.25$), j'ai placé:

* Un **Train** allant de $x = -0.25$à$x = 0.25$, centréen $x = 0.0$.

* Deuxéclats lumineuxémis vers l'intérieur depuis l'arrière (**B**) et l'avant
  (**F**) du trainà$t = 0.0$.

> setup: v=0.25, t=0.0, mode=emitter, tool=select
> object: train(name="Train", x=-0.25, t=0.0, v=0.25, color=purple)
> object: cone(name="B", x=-0.25, t=0.0, v=0.25, z=0.15, color=orange)
> object: cone(name="F", x=0.25, t=0.0, v=0.25, z=0.15, color=orange)

Avancez le curseur **Temps** jusqu'à$t = 0.25$.

Les deuxéclats se déplacentàla vitesse 1 dans ce référentiel et se rencontrent
au milieu du train.

> t = 0.25

## 3. Émetteur : vue depuis le sol

Passez dans le référentiel du sol ($v = 0.0$) et revenezà$t = 0.0$.

Notez que la pente des flashs lumineux est différente.

> v = 0.0
> t = 0.0

## 4. Émetteur : avancer le temps

Avancez le curseur **Temps** jusqu'à$t = 0.5$.

Les deux flashs se rencontrent toujoursà$t = 0.5$, mais pas au milieu des deux
drapeaux, car l'un des flashs est plus rapide que l'autre.

> t = 0.5

## 5. Éther : vue depuis le sol

Revenezà$t = 0.0$ et sélectionnez le mode **Hypothèse de l'éther**.

> t = 0.0
> mode = ether

## 6. Éther : les éclats se rencontrent au milieu

Avancez le curseur **Temps** jusqu'à$t = 0.25$.

Leséclats se rencontrent exactement au milieu des deux drapeaux, car la
vitesse de la lumière est identique dans le référentiel des drapeaux.

> t = 0.25

## 7. Éther : vue depuis le train

Revenezà$t = 0.0$ et passez dans le référentiel du train ($v = 0.25$).

> t = 0.0
> v = 0.25

## 8. Éther : les éclats manquent le milieu du train

Avancez le curseur **Temps** jusqu'à$t = 0.25$.

Leséclats ne se rencontrent pas au milieu du train, car ils ont des vitesses
différentes dans le référentiel du train.

> t = 0.25

## 9. Éther : pourquoi les faisceaux manquent le milieu

Dans le modèle de l'**Éther**, la lumière se déplaceà$c = 1$ par rapportà
l'éther immobile au sol, et non par rapport au train.

Parce que le train avanceà$v = 0.25$ :

* Le faisceau avant (**F**) se précipite vers le centreà$1 + 0.25 = 1.25$ et
  l'atteint tôt ($t = 0.20$).

* Le faisceau arrière (**B**) peineàrattraper le centreà$1 - 0.25 = 0.75$ et
  arrive tard ($t = 0.33$).

Cliquez sur **Continuer** pour découvrir les résultats expérimentaux.

> ok

## 10. Résultats expérimentaux

Les expériences ont démontréque la vitesse de la lumièreétait rigoureusement
la même dans tous les référentiels, que la source soit immobile ou en
mouvement !

Démarrez le tutoriel suivant pour explorer les conséquences de ce résultat.

> ok
