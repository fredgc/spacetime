# 3. Pastovus šviesos greitis ir vienalaikiškumas

Sužinokite, kodėl stebėtojai nesutaria, ar duįvykiai vyksta tuo pačiu metu, ir
kaip vienalaikiškumo reliatyvumas išplaukia išpastovausšviesos greičio.

## 1. Traukinys su centriniu šviesos blyksniu

Pradėkime traukinio, judančio $v = 0.25$ greičiu, atskaitos sistemoje.

Traukinys tęsiasi nuo $x = -0.25$ iki $x = 0.25$ (rimties ilgis $0.50$).
Pasirinkite **Pridėti**, pasirinkite **Šviesos kūgis** ir spustelėkite
traukinio centre $(x = 0.0, z = 0.15)$.

> reset
> setup: v=0.25, t=0.0, mode=lorentz, tool=add, type=cone
> object: train(name="Train", x=-0.25, t=0.0, v=0.25, color=purple)
> add = cone(name="Flash", x=0.0, t=0.0, z=0.15, color=orange, side=true)

## 2. Vienalaikiai smūgiai traukinio sistemoje

Pastumkite **Laiko** slankiklįiki $t = 0.25$.

Traukinio sistemoješviesa sklinda greičiu $c = 1$įabi puses. Abu blyksniai
traukinio galus pasiekia tuo pačiu metu ($t = 0.25$)!

> t = 0.25

## 3. Perėjimas į žemės sistemą

Nustatykite **Greitį**į$v = 0.00$ ir laikąį$t = 0.00$.Šviesa vis tiek sklinda
greičiu $c = 1$ ($45^\circ$ kampu)!

> v = 0.0
> t = 0.0

## 4. Šviesa pasiekia traukinio galą

Pastumkite **Laiko** slankiklįiki $t = 0.19$. Galinis traukinio galas skuba
priešpriešiais spinduliui ir susitinka anksčiau ties $t \approx 0.19$.

> t = 0.19

## 5. Pažymėkite įvykį B

Pasirinkite **Pridėti**, pasirinkite **Įvykis** ir pažymėkiteįvykį**B** ties
$(x = -0.19, t = 0.19)$.

> add = event(name="B", x=-0.19, t=0.19, color=red)

## 6. Šviesa pasiekia traukinio priekį

Pastumkite **Laiką** iki $t = 0.32$. Priekinis galas tolo nuošviesos, todėl
spindulys jįpavijo tik ties $t \approx 0.32$.

> t = 0.32

## 7. Pažymėkite įvykį F

Pažymėkiteįvykį**F** ties $(x = 0.32, t = 0.32)$.

> add = event(name="F", x=0.32, t=0.32, color=green)

## 8. Grįžimas į traukinio sistemą

Nustatykite **Greitį** atgalį$v = 0.25$.

> reset
> setup: v=0.0, t=0.32, mode=lorentz, tool=select
> object: train(name="Train", x=-0.25, t=0.0, v=0.25, color=purple)
> object: cone(name="Flash", x=0.0, t=0.0, z=0.15, color=orange)
> object: event(name="B", x=-0.19, t=0.19, color=red)
> object: event(name="F", x=0.32, t=0.32, color=green)
> v = 0.25

## 9. Vėl vienalaikiai!

Pastumkite **Laiką** iki $t = 0.25$. Traukinio sistemoje abuįvykiai vyksta
vienu metu!

* Traukinio sistemojeįvykiai yra **vienalaikiai** ($t = 0.25$).

* Žemės sistemoje **B**įvyksta pirmas ($t = 0.19$), o **F**–antras ($t =
  0.32$).

> t = 0.25

## 10. Vienalaikiškumo reliatyvumas

Absoliutaus vienalaikiškumo nėra. Du judantys stebėtojai nesutars dėl tolimų
įvykiųlaiko eiliškumo.

> ok
