# 1. Introduction : utilisation de l'outil Spacetime

Apprenezàtracer des diagrammes d'espace-temps de Minkowski,àmodifier des
objets etàexplorer des référentiels.

## 1. Description de l'affichage

Bienvenue dans l'outil relativiste de dessin Spacetime ! L'écran est diviséen
deux vues :

* **Diagramme d'espace-temps (en haut)** : L'espace ($x$) est sur l'axe
  horizontal et le temps ($t$) sur l'axe vertical, avec des unités oùla
  vitesse de la lumière est $c = 1$.

* **Vue de l'observateur (en bas)** : Montre une coupe animée 1D de ce que
  l'observateur voitàl'instant actuel $t$ (marquépar la barre horizontale dans
  le diagramme d'espace-temps).

Cliquez sur **Continuer** pour placer des objets sur le diagramme.

> reset
> setup: v=0.0, t=0.0, mode=lorentz
> ok

## 2. Ajouter un événement

La barre d'outils située au-dessus du diagramme permet d'alterner entre
**Sélectionner** et **Ajouter**, et de choisir le type d'objetàcréer.

Basculez sur **Ajouter**, choisissez **Événement**, puis cliquez sur la cible
clignotanteà$(x = 0.0, t = 0.5)$ (ou cliquez sur **Faire pour moi**).

> add = event(x=0.0, t=0.5)

## 3. Lignes d'univers, cônes de lumière et instants

En plus desévénements isolés, vous pouvez tracer :

* **Positions (Personne, Train, Grange, Drapeau, Horloge)** : Lignes
  représentant des objets se déplaçant dans le temps (lignes d'univers).

* **Cône de lumière** : Deux rayons lumineux s'étendant vers la gauche et la
  droite avec une pente $\pm 1$ (puisque $c = 1$).

* **Instant** : Une ligne reliant tous lesévénements qui se produisent au même
  moment pour un observateur.

L'outil **Ajouter**étant actif, choisissez **Cône de lumière** et cliquez sur
l'origine $(x = 0.0, t = 0.0)$ pour ajouter unéclat lumineux.

> add = cone(x=0.0, t=0.0)

## 4. Sélectionner des objets

Pour examiner ou modifier un objet existant, passez en mode **Sélectionner**
et cliquez sur l'objet dans le diagramme. (Cliquer et faire glisser sur une
zone vide permet de déplacer la vue.)

Nous avons ajoutéune personne nommée **Alice**à$x = -0.5$. Passez en mode
**Sélectionner** et cliquez sur la ligne d'univers d'Alice pour la
sélectionner.

> object: person(name="Alice", x=-0.5, t=0.0, v=0.0, color=blue)
> select = Alice

## 5. Déplacer et modifier des objets

Lorsqu'un objet est sélectionné, vous pouvez modifier son nom ou sa couleur
dans la barre d'outils supérieure, le supprimer ou le faire glisser vers une
nouvelle position.

Faites glisser **Alice** vers la droite jusqu'à$x = 0.5$ (ou cliquez sur
**Faire pour moi**).

> move = Alice(x=0.5, tol=0.25)

## 6. Animer le temps

Sous la vue de l'observateur se trouve le curseur **Temps**, qui déplace la
coupe temporelle $t$ vers le haut ou vers le bas.

Nous avons placéun **Train** immobileà$x = -0.25$ et **Alice** se déplaçant
vers la droiteàla vitesse $v = 0.5$. Déplacez le curseur **Temps**à$t = 0.5$
et observez les rayons de lumière s'étendre et Alice dépasser le train !

> reset
> setup: v=0.0, t=0.0, mode=lorentz, tool=select
> object: event(name="E1", x=0.0, t=0.5, color=red)
> object: cone(name="L1", x=0.0, t=0.0, color=orange)
> object: train(name="Train", x=-0.25, t=0.0, v=0.0, color=green)
> object: person(name="Alice", x=0.0, t=0.0, v=0.5, color=blue)
> t = 0.5

## 7. Changer la vitesse de l'observateur

Sous le curseur du temps se trouve le curseur **Vitesse**. Il contrôle la
vitesse $v$ de notre référentiel. Tout nouvel objet partagera automatiquement
la vitesse actuelle de l'observateur.

Déplacez le curseur **Vitesse**à$v = 0.50$ pour passer dans le référentiel
d'Alice.

> v = 0.5

## 8. Relativité du mouvement

Dans le référentiel d'Alice ($v = 0.50$), sa ligne d'univers est verticale
(elle est immobile) tandis que celle du train est inclinée vers la gauche !

Comme les lois de la physique sont relatives, il est tout aussi valable de
dire que le train passe devant Alice que de revenirà$v = 0.0$ et d'affirmer
qu'Alice passe devant le train.

Cliquez sur **Continuer** pour terminer cette introduction !

> ok
