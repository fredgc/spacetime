# 2. Pastovus šviesos greitis ir reliatyvumas

Ką reiškia, kad šviesos greitis yra pastovus?

## 1. Eteris prieš šaltinio greitį

PriešEinšteinąmokslininkai nustatė, kadšviesos greitis vakuume yra pastovus.
Tačiau pastovus kieno atžvilgiu?

Einšteinas pradėjo nuo mintinio eksperimento: jei sėdime traukinyje, geriame
šaltibarščius, išvažiuojame išVilniaus geležinkelio stoties ir pasiunčiame
šviesos blyksnį, aršviesos greitis yra santykinisžemės, ar traukinio
atžvilgiu?

* **Eterio teorija**:šviesa yra banga, sklindanti nejudančioje visuotinėje
  terpėje („šviesąnešančiame eteryje“). Jos greitis eterio atžvilgiu visada
  yra $c = 1$, nepriklausomai nuošaltinio judėjimo.

* **Šaltinio (spinduolio) teorija**:šviesa susideda išdalelių, kuriasšaltinis
  išspinduliuoja greičiu $c = 1$šaltinio atžvilgiu. Jeišaltinis juda greičiu
  $v$, pirmyn sklindantis spindulys juda greičiu $c + v$, o atgal–$c - v$.

Išbandykime abi teorijas. Pirmiausia pažvelkimeįšaltinio hipotezę. Pridėjau
dvi vėliavas atskaitos sistemoje $v = 0$.

Perjunkiteį**Šaltinio greitis** ir nustatykite stebėtojo greitį$v = 0.25$.

> reset
> setup: v=0.0, t=0.0, mode=lorentz, tool=select
> object: flag(name="BF", x=-0.25, t=0.0, v=0.0, color=teal)
> object: flag(name="FF", x=0.25, t=0.0, v=0.0, color=teal)
> mode = emitter
> v = 0.25

## 2. Traukinys su blyksniais abiejuose galuose

Šioje atskaitos sistemoje ($v = 0.25$) patalpinau:

* **Traukinį** nuo $x = -0.25$ iki $x = 0.25$, kurio centras yra ties $x =
  0.0$.

* Duįvidųnukreiptusšviesos blyksnius (oranžinius), išspinduliuotus ištraukinio
  galo (**B**) ir priekio (**F**) laiku $t = 0.0$.

> setup: v=0.25, t=0.0, mode=emitter, tool=select
> object: train(name="Train", x=-0.25, t=0.0, v=0.25, color=purple)
> object: cone(name="B", x=-0.25, t=0.0, v=0.25, z=0.15, color=orange)
> object: cone(name="F", x=0.25, t=0.0, v=0.25, z=0.15, color=orange)

Pastumkite **Laiko** slankiklįiki $t = 0.25$.

Atkreipkite dėmesį, kad abu blyksniaišioje sistemoje juda greičiu 1 ir
susitinka traukinio viduryje.

> t = 0.25

## 3. Šaltinis: vaizdas nuo žemės

Pereikiteįžemės atskaitos sistemą($v = 0.0$) ir grįžkiteįlaiką$t = 0.0$.

Blyksniųposvyris dabar skiriasi.

> v = 0.0
> t = 0.0

## 4. Šaltinis: laiko pastūmimas

Pastumkite **Laiko** slankiklįiki $t = 0.5$.

Blyksniai vis dar susitinka ties $t = 0.5$, tačiau ne tarp vėliavųvidurio, nes
vienas blyksnis yra greitesnis užkitą.

> t = 0.5

## 5. Eteris: vaizdas nuo žemės

Grįžkiteį$t = 0.0$ ir perjunkiteį**Eterio hipotezė**.

> t = 0.0
> mode = ether

## 6. Eteris: blyksniai susitinka viduryje

Pastumkite **Laiko** slankiklįiki $t = 0.25$.

Blyksniai susitinka tiksliai vėliavųviduryje, nesšviesos greitis vėliavų
atskaitos sistemoje yra vienodasįabi puses.

> t = 0.25

## 7. Eteris: vaizdas iš traukinio

Grįžkiteį$t = 0.0$ ir perjunkiteįtraukinio sistemą($v = 0.25$).

> t = 0.0
> v = 0.25

## 8. Eteris: blyksniai prasilenkia su traukinio viduriu

Pastumkite **Laiko** slankiklįiki $t = 0.25$.

Blyksniai nesusitinka traukinio viduryje, nes traukinio atžvilgiu jie turi
skirtingus greičius.

> t = 0.25

## 9. Eteris: kodėl spinduliai nesusitinka

Pagal **Eterio** modelįšviesa juda greičiu $c = 1$ nejudančiožemės eterio
atžvilgiu, o ne traukinio atžvilgiu. Kadangi traukinys juda pirmyn $v = 0.25$
greičiu, priekinis spindulys centrąpasiekia anksčiau ($t = 0.20$), o galinis–
vėliau ($t = 0.33$).

Spustelėkite **Tęsti**, kad sužinotumėte eksperimentinius rezultatus.

> ok

## 10. Eksperimentiniai rezultatai

Eksperimentai parodė, kadšviesos greitis yra vienodas visose atskaitos
sistemose, nepriklausomai nuo to, aršaltinis juda, ar stovi vietoje!

Pradėkite kitąpamoką, kad pamatytumėtešio fakto pasekmes.

> ok
