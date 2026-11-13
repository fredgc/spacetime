# 4. Dilatation du temps et horloges en mouvement

Découvrez pourquoi une horloge en mouvement tourne plus lentement qu'une
horloge immobile et comment la simultanéitérésout le paradoxe apparent.

## 1. L'horloge à lumière d'Alice

Nous avons placé**Alice** (avec une horloge en $x = 0.0$) et un **Miroir** (en
$x = 0.4$).Àl'événement **P1** $(0.0, 0.0)$, Aliceémet un rayon lumineux qui
frappe le miroir en **P2** $(0.4, 0.4)$ et revient vers Alice en **P3** $(0.0,
0.8)$.

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

## 2. Vérifier l'horloge d'Alice en P3

Avancez le curseur **Temps** jusqu'à$t = 0.8$ (événement **P3**).

L'horloge d'Alice indique $t = 0.80$ ($0.4 + 0.4 = 0.8$).

> t = 0.8

## 3. Passer dans le référentiel de Ben

Considérons cesévénements depuis le référentiel de **Ben**, qui se déplaceà$v
= -0.60$ ($\gamma = 1.25$). Réglez la **Vitesse** sur $v = -0.60$.

> object: clock(name="Ben", x=0.0, t=0.0, v=-0.6, color=purple)
> v = -0.6

## 4. Temps de parcours pour Ben

Le miroir fuyant le rayon incident, l'aller (**P1**à**P2**) dure $t = 0.80$.
Au retour (**P2**à**P3**), Alice vaàsa rencontre, ce qui ne prend que $0.20$
unité.

Déplacez le curseur **Temps**à$t = 1.0$.

> t = 1.0

## 5. Comparaison des horloges

Àl'événement **P3** ($t = 1.0$ pour Ben) :

* L'horloge de **Ben** indique $t = 1.00$.

* L'horloge d'**Alice** en **P3** indique toujours $t = 0.80$ !

Ben constate que l'horloge en mouvement d'Alice retarde d'un facteur $\gamma =
1.25$.

> ok

## 6. Marquer les instants pour Ben

Nous ajoutons deux **Instants** dans le référentiel de Ben : **I1**à$t = 0.0$
et **I2**à$t = 1.0$. Revenez au référentiel d'Alice ($v = 0.00$).

> object: instant(name="I1", x=0.0, t=0.0, v=-0.6, color=red)
> object: instant(name="I2", x=0.0, t=0.8, v=-0.6, color=purple)
> v = 0.0

## 7. La simultanéité résout le paradoxe

Dans le référentiel d'Alice, les lignes **I1** et **I2** ne sont plus
horizontales !À$t = 0.80$ pour Alice, l'horloge de Ben n'indique que $0.64$.
Chaque observateur voit l'horloge de l'autre ralentir en raison de plans de
simultanéitéinclinés différemment.

> ok
