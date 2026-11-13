# 7. Signaux supraluminiques et voyage dans le temps

Découvrez pourquoi l'envoi d'un signal supraluminique ou instantanéen
relativitérestreinte permet d'envoyer un message vers son propre passé.

## 1. Un message instantané (de A1 à A2)

Deux observateurs immobiles : **A1** ($x = -0.5$) et **A2** ($x = 0.5$).

* **P1** : A1 rédige un message.

* **P2** : A1 l'envoie instantanément via **MsgA** ($t = 0.6$).

* **P3** : A2 le reçoità$t = 0.6$.

* **P4** : A2 le transmetàun voyageur.

> reset
> setup: v=0.0, t=0.6, mode=lorentz, tool=select
> object: person(name="A1", x=-0.5, t=0.0, v=0.0, color=blue)
> object: person(name="A2", x=0.5, t=0.0, v=0.0, color=blue)
> object: event(name="P1", x=-0.5, t=0.5, z=0.15, color=red)
> object: event(name="P2", x=-0.5, t=0.6, z=0.15, color=red)
> object: instant(name="MsgA", x=0.0, t=0.6, v=0.0, color=orange)
> object: event(name="P3", x=0.5, t=0.6, z=0.15, color=red)
> object: event(name="P4", x=0.5, t=0.7, z=0.15, color=red)
> ok

## 2. Passer à un référentiel en mouvement

Deux observateurs, **B1** et **B2**, se déplacentà$v = 0.60$. Réglez la
**Vitesse** sur $v = 0.60$.

> object: person(name="B1", x=-0.5, t=0.5, v=0.6, color=green)
> object: person(name="B2", x=0.5, t=0.7, v=0.6, color=green)
> v = 0.6

## 3. P4 se produit avant P1 !

Dans le référentiel mobile, **P4** a lieuà$t = 0.50$ et **P1**à$t = 1.00$ : A2
remet le messageàB2 *avant* que A1 ne l'aitécrit ! Avancez le tempsà$t =
0.70$.

> t = 0.7

## 4. B2 envoie une réponse instantanée à B1

B2 renvoie le message via **MsgB**àB1, qui le reçoit en **P6** ($t = 0.70$).
Revenezà$v = 0.00$.

> object: event(name="P5", x=0.65, t=0.95, z=0.15, color=red)
> object: instant(name="MsgB", x=0.65, t=0.95, v=0.6, color=purple)
> object: event(name="P6", x=-0.725, t=0.125, color=red)
> v = 0.0

## 5. Une boucle temporelle fermée

$$\text{P1} \rightarrow \text{P2} \rightarrow \text{P3} \rightarrow \text{P4} \rightarrow \text{P5} \rightarrow \text{P6} \rightarrow \text{P1}$$

B1 reçoit le messageà$t = 0.125$ et peut le donneràA1 *avant* que ce dernier
ne l'ait rédigéà$t = 0.50$ ! Les signaux supraluminiques mènent inévitablement
àdes paradoxes de causalité.

> ok
