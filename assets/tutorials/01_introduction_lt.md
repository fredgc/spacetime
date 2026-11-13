# 1. Įvadas: „Spacetime“ įrankio naudojimas

Sužinokite, kaip braižyti Minkovskio erdvėlaikio diagramas, redaguoti objektus
ir nagrinėti atskaitos sistemas.

## 1. Kas rodoma ekrane

Sveiki atvykęįreliatyvistinio erdvėlaikio braižymoįrankį! Ekranas padalytasįdu
vaizdus:

* **Erdvėlaikio diagrama (viršuje)**: erdvė($x$) yra horizontalioje ašyje, o
  laikas ($t$)–vertikalioje ašyje, matuojant vienetais, kuršviesos greitis $c
  = 1$.

* **Stebėtojo vaizdas (apačioje)**: rodo 1D animuotąvaizdą, kąstebėtojas mato
  dabartiniu laiko momentu $t$ (pažymėtu horizontalia juosta erdvėlaikio
  diagramoje).

Spustelėkite **Tęsti**, kad pradėtumėte dėti objektusįdiagramą.

> reset
> setup: v=0.0, t=0.0, mode=lorentz
> ok

## 2. Įvykio pridėjimas

Viršdiagramos esantiįrankiųjuosta leidžia perjungti tarp **Pasirinkti** ir
**Pridėti**, taip pat pasirinkti kuriamo objekto tipą.

Perjunkiteįrankįį**Pridėti**, pasirinkite **Įvykis** ir spustelėkite mirksintį
taikinįerdvėlaikio drobėje ties $(x = 0.0, t = 0.5)$ (arba spustelėkite
**Atlikti užmane**).

> add = event(x=0.0, t=0.5)

## 3. Pasaulinės linijos, šviesos kūgiai ir momentai

Be pavieniųįvykių, galite braižyti:

* **Padėtys (Žmogus, Traukinys, Kluonas, Vėliava, Laikrodis)**: linijos,
  vaizduojančios laiku judančius objektus (pasaulinės linijos).

* **Šviesos kūgis**: dušviesos spinduliai, sklindantysįkairęirįdešinęsu
  posvyriu $\pm 1$ (kadangi $c = 1$).

* **Momentas**: linija, jungianti visusįvykius, kurie stebėtojui vyksta tuo
  pačiu metu.

Esant aktyviam **Pridėti**, pasirinkite **Šviesos kūgis** ir spustelėkite
koordinačiųpradžią$(x = 0.0, t = 0.0)$, kad pridėtumėtešviesos blyksnį.

> add = cone(x=0.0, t=0.0)

## 4. Objektų pasirinkimas

Norėdami peržiūrėti ar modifikuoti esamąobjektą, perjunkiteįrankįį
**Pasirinkti** ir spustelėkite objektądiagramoje. (Spustelėjęir vilkdami
tuščiąerdvę, slenkate vaizdą.)

Pridėjomežmogųvardu **Alisa** ties $x = -0.5$. Perjunkiteį**Pasirinkti** ir
spustelėkite Alisos pasaulinęliniją, kad jąpasirinktumėte.

> object: person(name="Alice", x=-0.5, t=0.0, v=0.0, color=blue)
> select = Alice

## 5. Objektų perkėlimas ir redagavimas

Pasirinkęobjektą, viršutinėjeįrankiųjuostoje galite keisti jo pavadinimąar
spalvą, jįištrinti arba nuvilktiįnaująvietądrobėje.

Nuvilkite **Alisą**įdešinęiki $x = 0.5$ (arba spustelėkite **Atlikti už
mane**).

> move = Alice(x=0.5, tol=0.25)

## 6. Laiko animavimas

Po stebėtojo vaizdu yra **Laiko** slankiklis, judinantis dabartinęlaiko
atkarpą$t$ aukštyn iržemyn erdvėlaikio diagramoje.

Pastatėme stovintį**Traukinį** ties $x = -0.25$ ir paleidome **Alisą** judėtiį
dešinęgreičiu $v = 0.5$. Pastumkite **Laiko** slankiklįiki $t = 0.5$ ir
stebėkite, kaip sklindašviesos spinduliai, sužimbaįvykis ir Alisa pravažiuoja
traukinį!

> reset
> setup: v=0.0, t=0.0, mode=lorentz, tool=select
> object: event(name="E1", x=0.0, t=0.5, color=red)
> object: cone(name="L1", x=0.0, t=0.0, color=orange)
> object: train(name="Train", x=-0.25, t=0.0, v=0.0, color=green)
> object: person(name="Alice", x=0.0, t=0.0, v=0.5, color=blue)
> t = 0.5

## 7. Stebėtojo greičio keitimas

Po laiko slankikliu yra **Greičio** slankiklis. Jis valdo mūsųatskaitos
sistemos greitį$v$. Bet kuris naujai pridėtas objektas automatiškai perima
dabartinįstebėtojo greitį.

Pastumkite **Greičio** slankiklįiki $v = 0.50$, kad pereitumėteįAlisos
atskaitos sistemą.

> v = 0.5

## 8. Judėjimo reliatyvumas

Alisos atskaitos sistemoje ($v = 0.50$) jos pasaulinėlinija yra vertikali (ji
stovi vietoje), o traukinio pasaulinėlinija pasvirusiįkairę!

Kadangi fizikos dėsniai yra reliatyvūs, teiginys, kad traukinys pravažiuoja
pro Alisą, yra lygiavertis teiginiui, kad Alisa pravažiuoja pro traukinį.

Spustelėkite **Tęsti**, kad užbaigtumėteįvadą!

> ok
