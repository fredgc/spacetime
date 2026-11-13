# 6. Le paradoxe des jumeaux

Suivez une paire de jumeaux se séparantàvitesse relativiste avant de se
retrouver, et comprenez pourquoi le jumeau voyageur revient plus jeune.

## 1. Séparation à l'événement e1

**Alice** reste immobile ($v = 0.0$) tandis que **Bob** partà$v = 0.60$
($\gamma = 1.25$). Ils partent ensemble de **e1** $(0.0, 0.0)$.À$0.40$ sur sa
montre, Bob atteint l'événement de demi-tour **e2** $(0.3, 0.5)$.

> reset
> setup: v=0.0, t=0.0, mode=lorentz, tool=select
> object: clock(name="Alice", x=0.0, t=0.0, v=0.0, z=0.05, color=blue)
> object: clock(name="Bob", x=0.0, t=0.0, v=0.6, z=0.2, color=green)
> object: event(name="e1", x=0.0, t=0.0, z=0.0, color=red)
> object: event(name="e2", x=0.3, t=0.5, z=0.0, color=red)
> ok

## 2. Introduction du voyageur Carl

Plutôt que d'accélérer Bob, introduisons **Carl**, voyageant en sens inverseà
$v = -0.60$. Réglez la **Vitesse** sur $v = -0.60$.

> v = -0.6

## 3. Synchronisation de l'horloge de Carl en e2

La ligne d'univers de Carl croise **e2** et sa montre est synchronisée avec
celle de Bob ($t = 0.40$). Carl rejoint Alice en **e3** $(0.0, 1.0)$.

> object: clock(name="Carl", x=0.33, t=0.45, v=-0.6, z=0.15, color=purple)
> object: event(name="e3", x=0.0, t=1.0, z=0.0, color=red)
> ok

## 4. Retour au référentiel d'Alice

Réglez la **Vitesse** sur $v = 0.00$.

> v = 0.0

## 5. Comparaison des âges lors des retrouvailles (e3)

Avancez le **Temps**à$t = 1.0$ :

* L'horloge de **Carl** indique $t = 0.80$ ($0.40 + 0.40$).

* L'horloge d'**Alice** indique $t = 1.00$ !

Le jumeau voyageur revient plus jeune qu'Alice.

> t = 1.0

## 6. Pourquoi la situation n'est-elle pas symétrique ?

Dans le référentiel de Bob ($v = 0.60$), l'horloge d'Alice tourne certes au
ralenti, mais Carl va encore plus vite ($v_{\text{rel}} \approx -0.88$), de
sorte que son horloge retarde encore plus ! De plus, le retour dure bien plus
longtemps que l'aller dans ce référentiel.

> ok
