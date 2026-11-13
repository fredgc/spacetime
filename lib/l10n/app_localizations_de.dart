// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Spacetime-Zeichenwerkzeug';

  @override
  String get language => 'Sprache';

  @override
  String get systemDefault => 'Systemstandard';

  @override
  String get settings => 'Einstellungen';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get initializingSettings => 'Einstellungen werden initialisiert...';

  @override
  String get helpOptions => 'Hilfe-Optionen';

  @override
  String get aboutSpacetime => 'Über Spacetime';

  @override
  String get helpAndUserGuides => 'Hilfe & Benutzerhandbücher';

  @override
  String get developerDocs => 'Entwicklerdokumentation';

  @override
  String get close => 'Schließen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get saveAs => 'Speichern unter...';

  @override
  String get discard => 'Verwerfen';

  @override
  String get ok => 'OK';

  @override
  String get title => 'Titel';

  @override
  String get description => 'Beschreibung';

  @override
  String get objectName => 'Objektname';

  @override
  String get menuFile => 'Datei';

  @override
  String get menuTutorials => 'Tutorials';

  @override
  String get menuEdit => 'Bearbeiten';

  @override
  String get menuView => 'Ansicht';

  @override
  String get menuNew => 'Neu';

  @override
  String get menuOpen => 'Öffnen';

  @override
  String get menuReload => 'Neu laden';

  @override
  String get menuSave => 'Speichern';

  @override
  String get menuSaveAs => 'Speichern unter';

  @override
  String get menuEditDescription => 'Beschreibung bearbeiten';

  @override
  String get menuShare => 'Teilen';

  @override
  String get menuLogout => 'Abmelden';

  @override
  String get menuUndo => 'Rückgängig';

  @override
  String get menuRedo => 'Wiederholen';

  @override
  String get menuCut => 'Ausschneiden';

  @override
  String get menuCopy => 'Kopieren';

  @override
  String get menuPaste => 'Einfügen';

  @override
  String get menuDelete => 'Löschen';

  @override
  String get menuFitScene => 'Szene anpassen';

  @override
  String get lightSpeedLorentz => 'Lorentz-Transformation';

  @override
  String get lightSpeedLorentzTip => 'Die Lichtgeschwindigkeit ist konstant.';

  @override
  String get lightSpeedEther => 'Äther-Hypothese';

  @override
  String get lightSpeedEtherTip =>
      'Die Lichtgeschwindigkeit ist relativ zu einem bevorzugten globalen Bezugssystem.';

  @override
  String get lightSpeedEmitter => 'Emitter-Geschwindigkeit';

  @override
  String get lightSpeedEmitterTip =>
      'Die Lichtgeschwindigkeit ist relativ zu ihrer Quelle.';

  @override
  String get toolSelect => 'Auswählen';

  @override
  String get toolAdd => 'Hinzufügen';

  @override
  String get drawTypeEvent => 'Ereignis';

  @override
  String get drawTypeInstant => 'Moment';

  @override
  String get drawTypeCone => 'Lichtkegel';

  @override
  String get drawTypeClock => 'Uhr';

  @override
  String get drawTypePerson => 'Person';

  @override
  String get drawTypeTrain => 'Zug';

  @override
  String get drawTypeBarn => 'Scheune';

  @override
  String get drawTypeFlag => 'Flagge';

  @override
  String get time => 'Zeit';

  @override
  String get velocity => 'Geschwindigkeit';

  @override
  String get unsavedSceneTitle => 'Nicht gespeicherte Szene';

  @override
  String get unsavedSceneBody1 => 'Die Zeichnung wurde geändert.';

  @override
  String get unsavedSceneBody2 => 'Möchten Sie sie speichern?';

  @override
  String get confirmPropertiesTitle =>
      'Eigenschaften vor dem Speichern bestätigen';

  @override
  String get tutorialCompletedTitle => 'Tutorial abgeschlossen!';

  @override
  String tutorialCompletedMessage(String title) {
    return 'Hervorragend! Sie haben alle Schritte in $title abgeschlossen. Sie können nun weiter mit der Szene experimentieren und Ihr Ergebnis speichern.';
  }

  @override
  String get tutorialFinishKeepScene => 'Fertigstellen (Szene behalten)';

  @override
  String get tutorialDoItForMe => 'Für mich ausführen';

  @override
  String get tutorialBack => 'Zurück';

  @override
  String get tutorialContinue => 'Weiter';

  @override
  String get tutorialFinish => 'Fertigstellen';

  @override
  String tutorialStepCounter(int current, int total) {
    return 'Schritt $current von $total';
  }

  @override
  String get helpDocumentationAndGuides => 'Dokumentation & Anleitungen';

  @override
  String get helpUserGuides => 'Benutzerhandbücher';

  @override
  String get helpAbout => 'Über Spacetime';

  @override
  String get helpPrivacy => 'Datenschutzerklärung';

  @override
  String get helpTerms => 'Nutzungsbedingungen';

  @override
  String get helpOverview => 'Übersicht';

  @override
  String get helpControls => 'Symbolleiste und Schieberegler';

  @override
  String get helpObjects => 'Raumzeit-Objekte';

  @override
  String get helpTransformations => 'Relativistische Transformationen';

  @override
  String get helpFiles => 'Dateiverwaltung';

  @override
  String get helpReadme => 'Liesmich';

  @override
  String get helpDeveloperGuide => 'Entwicklerhandbuch';

  @override
  String get helpProjectPlan => 'Projektplan';

  @override
  String get themeMode => 'Design';

  @override
  String get systemTheme => 'Systemstandard';

  @override
  String get lightTheme => 'Helles Design';

  @override
  String get darkTheme => 'Dunkles Design';

  @override
  String get semanticsLanguageSwitcher => 'Anwendungssprache auswählen';

  @override
  String get semanticsDrawerOpen => 'Navigationsleiste öffnen';

  @override
  String get semanticsDrawerClose => 'Navigationsleiste schließen';

  @override
  String get semanticsTimeSlider => 'Simulationszeit anpassen';

  @override
  String get semanticsVelocitySlider =>
      'Beobachter-Bezugssystemgeschwindigkeit anpassen';

  @override
  String get semanticsSpacetimeCanvas => 'Minkowski-Raumzeitdiagramm-Leinwand';

  @override
  String get semanticsObserverCanvas => 'Beobachter-Seitenansicht-Leinwand';
}
