# 5. Ilgio sutrumpėjimas ir kluono paradoksas

Sužinokite, kaip judantys objektai sutrumpėja judėjimo kryptimi ir kaip
vienalaikiškumas išsprendžia traukinio bei kluono paradoksą.

## 1. Atstumas rimties sistemoje

Dužmonės, **A1** ($x = -1.0$) ir **A2** ($x = 1.0$), yra nutolę$2.0$ vienetų
atstumu sistemoje $v = 0.00$.

> reset
> setup: v=0.0, t=0.0, mode=lorentz, tool=select
> object: person(name="A1", x=-1.0, t=0.0, v=0.0, color=blue)
> object: person(name="A2", x=1.0, t=0.0, v=0.0, color=blue)
> ok

## 2. Ilgio sutrumpėjimas dideliu greičiu

Nustatykite **Greitį**į$v = 0.87$ ($\gamma \approx 2.0$). Atstumas tarp A1 ir
A2 sutrumpėja perpus–iki $1.0$ vieneto!

> v = 0.87

## 3. Traukinio ir kluono sąranka

Stovintis **Kluonas** ($v = 0.0$, plotis $0.50$) ir judantis **Traukinys** ($v
= 0.60$, rimties plotis $0.50$). Nustatykite greitį$v = 0.00$.

> reset
> setup: v=0.87, t=0.0, mode=lorentz, tool=select
> object: barn(name="Barn", x=-0.25, t=0.0, v=0.0, color=green)
> object: train(name="Train", x=-0.20, t=0.0, v=0.6, color=orange)
> v = 0.0

## 4. Traukinys kluono viduje

Ties $t = 0.0$ kluono sistemoje traukinys sutrumpėja iki $0.40$ ($x = -0.20$
iki $0.20$) ir telpa kluone! Pridėkite **Įvykį** ties $(x = 0.2, t = 0.0)$.

> object: event(name="B", x=-0.20, t=0.0, color=red)
> add = event(x=0.2, t=0.0)

## 5. Perėjimas į traukinio sistemą

Nustatykite **Greitį**į$v = 0.60$. Traukinio ilgis yra $0.50$, o kluonas
sutrumpėjęs iki $0.40$–traukinys ilgesnis užkluoną!

> reset
> setup: v=0.0, t=0.0, mode=lorentz, tool=select
> object: barn(name="Barn", x=-0.25, t=0.0, v=0.0, color=green)
> object: train(name="Train", x=-0.20, t=0.0, v=0.6, color=orange)
> object: event(name="B", x=-0.20, t=0.0, color=red)
> object: event(name="F", x=0.20, t=0.0, color=blue)
> v = 0.6

## 6. F pasiekia išėjimą pirmas

Traukinio sistemoje **F** ir **B** nėra vienalaikiai! Ties $t = -0.15$ (**F**)
priekis jau prie durų, o galas dar toli lauke.

> t = -0.15

## 7. B įvažiuoja vėliau

Ties $t = 0.15$ (**B**), kai galasįvažiuoja, priekis jau seniai išvažiavęs!
Įvykiai yra vienalaikiai tik kluono sistemoje.

> t = 0.15
