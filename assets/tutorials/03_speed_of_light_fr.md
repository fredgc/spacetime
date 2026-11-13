# 3. Vitesse constante de la lumière et simultanéité

Découvrez pourquoi différents observateurs ne sont pas d'accord sur la
simultanéitéde deuxévénements, et comment la relativitéde la simultanéité
découle de la vitesse constante de la lumière.

## 1. Train avec éclair lumineux central

Commençons dans le référentiel d'un train se déplaçantà$v = 0.25$.

Le train violet s'étend de $x = -0.25$à$x = 0.25$ (longueur propre $0.50$),
centréen $x = 0.0$.

Sélectionnez **Ajouter**, choisissez **Cône de lumière** et cliquez au centre
du train $(x = 0.0, z = 0.15)$ dans la vue inférieure pourémettre un flash
lumineux.

> reset
> setup: v=0.25, t=0.0, mode=lorentz, tool=add, type=cone
> object: train(name="Train", x=-0.25, t=0.0, v=0.25, color=purple)
> add = cone(name="Flash", x=0.0, t=0.0, z=0.15, color=orange, side=true)

## 2. Impacts simultanés dans le référentiel du train

Avancez le curseur **Temps** jusqu'à$t = 0.25$.

Dans le référentiel du train, la lumière s'étendà$c = 1$ dans les deux sens.
Les deux extrémités sontàégale distance ($0.25$).

Les deuxéclats frappent les extrémités du train au même instant ($t = 0.25$) !

> t = 0.25

## 3. Passer dans le référentiel du sol

Passons au référentiel du sol : réglez la **Vitesse** sur $v = 0.00$ et le
**Temps** sur $t = 0.00$.

Selon la relativitérestreinte (**Lorentz**), la lumière voyage toujoursà$c =
1$ (pentesà$45^\circ$) même si le train est en mouvement !

> v = 0.0
> t = 0.0

## 4. La lumière touche l'arrière du train

Avancez le curseur **Temps** jusqu'à$t = 0.19$.

Dans le référentiel du sol, l'arrière du train avance vers le rayon lumineux
et le rencontre plus tôt,à$t \approx 0.19$.

> t = 0.19

## 5. Marquer l'événement B

Basculez sur **Ajouter**, choisissez **Événement** et placez l'événement **B**
à$(x = -0.19, t = 0.19)$.

> add = event(name="B", x=-0.19, t=0.19, color=red)

## 6. La lumière touche l'avant du train

Avancez le **Temps** jusqu'à$t = 0.32$.

L'avant fuyant la lumière, le faisceau met plus de tempsàle rattraper et
l'atteintà$t \approx 0.32$.

> t = 0.32

## 7. Marquer l'événement F

Placez l'événement **F**àl'intersection $(x = 0.32, t = 0.32)$.

> add = event(name="F", x=0.32, t=0.32, color=green)

## 8. Retour au référentiel du train

Réglez le curseur **Vitesse** sur $v = 0.25$ pour revenir au référentiel du
train.

> reset
> setup: v=0.0, t=0.32, mode=lorentz, tool=select
> object: train(name="Train", x=-0.25, t=0.0, v=0.25, color=purple)
> object: cone(name="Flash", x=0.0, t=0.0, z=0.15, color=orange)
> object: event(name="B", x=-0.19, t=0.19, color=red)
> object: event(name="F", x=0.32, t=0.32, color=green)
> v = 0.25

## 9. Simultanés à nouveau !

Réglez le curseur **Temps** sur $t = 0.25$.

Dans le référentiel du train ($v = 0.25$), les deuxévénements **B** et **F**
se produisent au même instant $t = 0.25$ !

Lorsqu'on change de référentiel, la ligne de simultanéités'incline :

* Dans le train, lesévénements sont **simultanés** ($t = 0.25$).

* Au sol, **B** a lieu en premier ($t = 0.19$) et **F** en second ($t =
  0.32$).

> t = 0.25

## 10. Relativité de la simultanéité

La simultanéitéabsolue n'existe pas. Deux observateurs en mouvement relatif
n'accordent pas le même ordre chronologiqueàdesévénements distants.

Cliquez sur **Continuer** pour achever ce tutoriel.

> ok
