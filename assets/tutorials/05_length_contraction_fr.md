# 5. Contraction des longueurs et paradoxe du train

Découvrez comment les objets en mouvement se contractent dans le sens de leur
déplacement et comment la simultanéitérésout le paradoxe du train et de la
grange.

## 1. Distance dans le référentiel propre

Deux personnes immobiles, **A1** ($x = -1.0$) et **A2** ($x = 1.0$), sont
distantes de $2.0$ unitésà$v = 0.00$.

> reset
> setup: v=0.0, t=0.0, mode=lorentz, tool=select
> object: person(name="A1", x=-1.0, t=0.0, v=0.0, color=blue)
> object: person(name="A2", x=1.0, t=0.0, v=0.0, color=blue)
> ok

## 2. Contraction des longueurs à grande vitesse

Réglez la **Vitesse** sur $v = 0.87$ ($\gamma \approx 2.0$). La distance entre
A1 et A2 n'est plus que de $1.0$ unitéenviron !

> v = 0.87

## 3. Configuration du train et de la grange

Une **Grange** immobile ($v = 0.0$, largeur $0.50$) et un **Train** en
mouvement ($v = 0.60$, longueur propre $0.50$). Réglez la **Vitesse** sur $v =
0.00$.

> reset
> setup: v=0.87, t=0.0, mode=lorentz, tool=select
> object: barn(name="Barn", x=-0.25, t=0.0, v=0.0, color=green)
> object: train(name="Train", x=-0.20, t=0.0, v=0.6, color=orange)
> v = 0.0

## 4. Marquer le train dans la grange

À$t = 0.0$ dans le référentiel de la grange, le train est contractéà$0.40$ ($x
= -0.20$à$0.20$) : il tient entièrement dans la grange !

Ajoutez un **Événement**à$(x = 0.2, t = 0.0)$ marquant l'avant du train.

> object: event(name="B", x=-0.20, t=0.0, color=red)
> add = event(x=0.2, t=0.0)

## 5. Passer au référentiel du train

Réglez la **Vitesse** sur $v = 0.60$. Le train mesure $0.50$ tandis que la
grange est contractéeà$0.40$ : le train est plus long que la grange !

> reset
> setup: v=0.0, t=0.0, mode=lorentz, tool=select
> object: barn(name="Barn", x=-0.25, t=0.0, v=0.0, color=green)
> object: train(name="Train", x=-0.20, t=0.0, v=0.6, color=orange)
> object: event(name="B", x=-0.20, t=0.0, color=red)
> object: event(name="F", x=0.20, t=0.0, color=blue)
> v = 0.6

## 6. L'avant sort en premier

Dans le référentiel du train, **F** et **B** ne sont pas simultanés !À$t =
-0.15$ (**F**), l'avant atteint la sortie alors que l'arrière est encore
dehors.

> t = -0.15

## 7. L'arrière entre plus tard

À$t = 0.15$ (**B**), lorsque l'arrière entre, l'avant a déjàlargement dépassé
la sortie ! Les deuxévénements ne sont simultanés que dans le référentiel de
la grange.

> t = 0.15
