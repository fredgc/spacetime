// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Lithuanian (`lt`).
class AppLocalizationsLt extends AppLocalizations {
  AppLocalizationsLt([String locale = 'lt']) : super(locale);

  @override
  String get appTitle => 'Erdvėlaikio braižymo įrankis';

  @override
  String get language => 'Kalba';

  @override
  String get systemDefault => 'Sistemos numatytoji';

  @override
  String get settings => 'Nustatymai';

  @override
  String get settingsTitle => 'Nustatymai';

  @override
  String get initializingSettings => 'Inicijuojami nustatymai...';

  @override
  String get helpOptions => 'Pagalbos parinktys';

  @override
  String get aboutSpacetime => 'Apie „Spacetime“';

  @override
  String get helpAndUserGuides => 'Pagalba ir naudotojo vadovai';

  @override
  String get developerDocs => 'Kūrėjo dokumentacija';

  @override
  String get close => 'Užverti';

  @override
  String get cancel => 'Atsisakyti';

  @override
  String get save => 'Išsaugoti';

  @override
  String get saveAs => 'Išsaugoti kaip...';

  @override
  String get discard => 'Atmesti';

  @override
  String get ok => 'Gerai';

  @override
  String get title => 'Pavadinimas';

  @override
  String get description => 'Aprašas';

  @override
  String get objectName => 'Objekto pavadinimas';

  @override
  String get menuFile => 'Failas';

  @override
  String get menuTutorials => 'Mokymai';

  @override
  String get menuEdit => 'Taisa';

  @override
  String get menuView => 'Rodymas';

  @override
  String get menuNew => 'Naujas';

  @override
  String get menuOpen => 'Atverti';

  @override
  String get menuReload => 'Įkelti iš naujo';

  @override
  String get menuSave => 'Išsaugoti';

  @override
  String get menuSaveAs => 'Išsaugoti kaip';

  @override
  String get menuEditDescription => 'Redaguoti aprašą';

  @override
  String get menuShare => 'Bendrinti';

  @override
  String get menuLogout => 'Atsijungti';

  @override
  String get menuUndo => 'Atšaukti';

  @override
  String get menuRedo => 'Grąžinti';

  @override
  String get menuCut => 'Iškirpti';

  @override
  String get menuCopy => 'Kopijuoti';

  @override
  String get menuPaste => 'Įklijuoti';

  @override
  String get menuDelete => 'Pašalinti';

  @override
  String get menuFitScene => 'Talpinti sceną';

  @override
  String get lightSpeedLorentz => 'Lorenco transformacija';

  @override
  String get lightSpeedLorentzTip => 'Šviesos greitis yra pastovus.';

  @override
  String get lightSpeedEther => 'Eterio hipotezė';

  @override
  String get lightSpeedEtherTip =>
      'Šviesos greitis yra santykinis privilegijuotos visuotinės atskaitos sistemos atžvilgiu.';

  @override
  String get lightSpeedEmitter => 'Šaltinio greitis';

  @override
  String get lightSpeedEmitterTip =>
      'Šviesos greitis yra santykinis jos šaltinio atžvilgiu.';

  @override
  String get toolSelect => 'Pasirinkti';

  @override
  String get toolAdd => 'Pridėti';

  @override
  String get drawTypeEvent => 'Įvykis';

  @override
  String get drawTypeInstant => 'Momentas';

  @override
  String get drawTypeCone => 'Šviesos kūgis';

  @override
  String get drawTypeClock => 'Laikrodis';

  @override
  String get drawTypePerson => 'Žmogus';

  @override
  String get drawTypeTrain => 'Traukinys';

  @override
  String get drawTypeBarn => 'Kluonas';

  @override
  String get drawTypeFlag => 'Vėliava';

  @override
  String get time => 'Laikas';

  @override
  String get velocity => 'Greitis';

  @override
  String get unsavedSceneTitle => 'Neišsaugota scena';

  @override
  String get unsavedSceneBody1 => 'Brėžinys buvo pakeistas.';

  @override
  String get unsavedSceneBody2 => 'Ar norite jį išsaugoti?';

  @override
  String get confirmPropertiesTitle => 'Patvirtinkite savybes prieš išsaugant';

  @override
  String get tutorialCompletedTitle => 'Mokymas baigtas!';

  @override
  String tutorialCompletedMessage(String title) {
    return 'Puikiai atlikta! Užbaigėte visus „$title“ veiksmus. Dabar galite toliau tyrinėti sceną ir išsaugoti rezultatą.';
  }

  @override
  String get tutorialFinishKeepScene => 'Baigti (palikti sceną)';

  @override
  String get tutorialDoItForMe => 'Atlikti už mane';

  @override
  String get tutorialBack => 'Atgal';

  @override
  String get tutorialContinue => 'Tęsti';

  @override
  String get tutorialFinish => 'Baigti';

  @override
  String tutorialStepCounter(int current, int total) {
    return '$current veiksmas iš $total';
  }

  @override
  String get helpDocumentationAndGuides => 'Dokumentacija ir vadovai';

  @override
  String get helpUserGuides => 'Naudotojo vadovai';

  @override
  String get helpAbout => 'Apie „Spacetime“';

  @override
  String get helpPrivacy => 'Privatumo politika';

  @override
  String get helpTerms => 'Paslaugų teikimo sąlygos';

  @override
  String get helpOverview => 'Apžvalga';

  @override
  String get helpControls => 'Įrankių juosta ir slankikliai';

  @override
  String get helpObjects => 'Erdvėlaikio objektai';

  @override
  String get helpTransformations => 'Reliatyvistiniai virsmai';

  @override
  String get helpFiles => 'Failų tvarkymas';

  @override
  String get helpReadme => 'Skaityk mane';

  @override
  String get helpDeveloperGuide => 'Kūrėjo vadovas';

  @override
  String get helpProjectPlan => 'Projekto planas';

  @override
  String get themeMode => 'Tema';

  @override
  String get systemTheme => 'Sistemos tema';

  @override
  String get lightTheme => 'Šviesi tema';

  @override
  String get darkTheme => 'Tamsi tema';

  @override
  String get semanticsLanguageSwitcher => 'Pasirinkti programos kalbą';

  @override
  String get semanticsDrawerOpen => 'Atverti naršymo skydelį';

  @override
  String get semanticsDrawerClose => 'Užverti naršymo skydelį';

  @override
  String get semanticsTimeSlider => 'Reguliuoti modeliavimo laiką';

  @override
  String get semanticsVelocitySlider =>
      'Reguliuoti stebėtojo atskaitos sistemos greitį';

  @override
  String get semanticsSpacetimeCanvas =>
      'Minkovskio erdvėlaikio diagramos drobė';

  @override
  String get semanticsObserverCanvas => 'Stebėtojo šoninio vaizdo drobė';
}
