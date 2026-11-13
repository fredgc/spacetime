// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Spacetime Drawing Tool';

  @override
  String get language => 'Language';

  @override
  String get systemDefault => 'System Default';

  @override
  String get settings => 'Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get initializingSettings => 'Initializing Settings...';

  @override
  String get helpOptions => 'Help Options';

  @override
  String get aboutSpacetime => 'About Spacetime';

  @override
  String get helpAndUserGuides => 'Help & User Guides';

  @override
  String get developerDocs => 'Developer Docs';

  @override
  String get close => 'Close';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get saveAs => 'Save As...';

  @override
  String get discard => 'Discard';

  @override
  String get ok => 'OK';

  @override
  String get title => 'Title';

  @override
  String get description => 'Description';

  @override
  String get objectName => 'Object Name';

  @override
  String get menuFile => 'File';

  @override
  String get menuTutorials => 'Tutorials';

  @override
  String get menuEdit => 'Edit';

  @override
  String get menuView => 'View';

  @override
  String get menuNew => 'New';

  @override
  String get menuOpen => 'Open';

  @override
  String get menuReload => 'Reload';

  @override
  String get menuSave => 'Save';

  @override
  String get menuSaveAs => 'Save As';

  @override
  String get menuEditDescription => 'Edit Description';

  @override
  String get menuShare => 'Share';

  @override
  String get menuLogout => 'Log Out';

  @override
  String get menuUndo => 'Undo';

  @override
  String get menuRedo => 'Redo';

  @override
  String get menuCut => 'Cut';

  @override
  String get menuCopy => 'Copy';

  @override
  String get menuPaste => 'Paste';

  @override
  String get menuDelete => 'Delete';

  @override
  String get menuFitScene => 'Fit Scene';

  @override
  String get lightSpeedLorentz => 'Use Lorentz';

  @override
  String get lightSpeedLorentzTip => 'The speed of light is constant.';

  @override
  String get lightSpeedEther => 'Use Ether';

  @override
  String get lightSpeedEtherTip =>
      'The speed of light is relative to a preferred global frame.';

  @override
  String get lightSpeedEmitter => 'Use Emitter Speed';

  @override
  String get lightSpeedEmitterTip =>
      'The speed of light is relative to its emitter.';

  @override
  String get toolSelect => 'Select';

  @override
  String get toolAdd => 'Add';

  @override
  String get drawTypeEvent => 'Event';

  @override
  String get drawTypeInstant => 'Instant';

  @override
  String get drawTypeCone => 'Light Cone';

  @override
  String get drawTypeClock => 'Clock';

  @override
  String get drawTypePerson => 'Person';

  @override
  String get drawTypeTrain => 'Train';

  @override
  String get drawTypeBarn => 'Barn';

  @override
  String get drawTypeFlag => 'Flag';

  @override
  String get time => 'Time';

  @override
  String get velocity => 'Velocity';

  @override
  String get unsavedSceneTitle => 'Unsaved Scene';

  @override
  String get unsavedSceneBody1 => 'The drawing has been modified.';

  @override
  String get unsavedSceneBody2 => 'Would you like to save it?';

  @override
  String get confirmPropertiesTitle => 'Confirm Properties Before Saving';

  @override
  String get tutorialCompletedTitle => 'Tutorial Completed!';

  @override
  String tutorialCompletedMessage(String title) {
    return 'Great job! You have completed all steps in $title. You can now continue playing with the scene and save your result.';
  }

  @override
  String get tutorialFinishKeepScene => 'Finish (Keep Scene)';

  @override
  String get tutorialDoItForMe => 'Do it for me';

  @override
  String get tutorialBack => 'Back';

  @override
  String get tutorialContinue => 'Continue';

  @override
  String get tutorialFinish => 'Finish';

  @override
  String tutorialStepCounter(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get helpDocumentationAndGuides => 'Documentation & Guides';

  @override
  String get helpUserGuides => 'User Guides';

  @override
  String get helpAbout => 'About Spacetime';

  @override
  String get helpPrivacy => 'Privacy Policy';

  @override
  String get helpTerms => 'Terms of Service';

  @override
  String get helpOverview => 'Overview';

  @override
  String get helpControls => 'Toolbar and Sliders';

  @override
  String get helpObjects => 'Spacetime Objects';

  @override
  String get helpTransformations => 'Relativistic Transformations';

  @override
  String get helpFiles => 'File Management';

  @override
  String get helpReadme => 'Readme';

  @override
  String get helpDeveloperGuide => 'Developer Guide';

  @override
  String get helpProjectPlan => 'Project Plan';

  @override
  String get themeMode => 'Theme';

  @override
  String get systemTheme => 'System Theme';

  @override
  String get lightTheme => 'Light Theme';

  @override
  String get darkTheme => 'Dark Theme';

  @override
  String get semanticsLanguageSwitcher => 'Select application language';

  @override
  String get semanticsDrawerOpen => 'Open navigation drawer';

  @override
  String get semanticsDrawerClose => 'Close navigation drawer';

  @override
  String get semanticsTimeSlider => 'Adjust simulation time';

  @override
  String get semanticsVelocitySlider =>
      'Adjust observer reference frame velocity';

  @override
  String get semanticsSpacetimeCanvas => 'Spacetime Minkowski diagram canvas';

  @override
  String get semanticsObserverCanvas => 'Observer side view canvas';
}

/// The translations for English, as used in the United Kingdom (`en_GB`).
class AppLocalizationsEnGb extends AppLocalizationsEn {
  AppLocalizationsEnGb() : super('en_GB');

  @override
  String get appTitle => 'Spacetime Drawing Tool';

  @override
  String get language => 'Language';

  @override
  String get systemDefault => 'System Default';

  @override
  String get settings => 'Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get initializingSettings => 'Initialising Settings...';

  @override
  String get helpOptions => 'Help Options';

  @override
  String get aboutSpacetime => 'About Spacetime';

  @override
  String get helpAndUserGuides => 'Help & User Guides';

  @override
  String get developerDocs => 'Developer Docs';

  @override
  String get close => 'Close';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get saveAs => 'Save As...';

  @override
  String get discard => 'Discard';

  @override
  String get ok => 'OK';

  @override
  String get title => 'Title';

  @override
  String get description => 'Description';

  @override
  String get objectName => 'Object Name';

  @override
  String get menuFile => 'File';

  @override
  String get menuTutorials => 'Tutorials';

  @override
  String get menuEdit => 'Edit';

  @override
  String get menuView => 'View';

  @override
  String get menuNew => 'New';

  @override
  String get menuOpen => 'Open';

  @override
  String get menuReload => 'Reload';

  @override
  String get menuSave => 'Save';

  @override
  String get menuSaveAs => 'Save As';

  @override
  String get menuEditDescription => 'Edit Description';

  @override
  String get menuShare => 'Share';

  @override
  String get menuLogout => 'Log Out';

  @override
  String get menuUndo => 'Undo';

  @override
  String get menuRedo => 'Redo';

  @override
  String get menuCut => 'Cut';

  @override
  String get menuCopy => 'Copy';

  @override
  String get menuPaste => 'Paste';

  @override
  String get menuDelete => 'Delete';

  @override
  String get menuFitScene => 'Fit Scene';

  @override
  String get lightSpeedLorentz => 'Use Lorentz';

  @override
  String get lightSpeedLorentzTip => 'The speed of light is constant.';

  @override
  String get lightSpeedEther => 'Use Ether';

  @override
  String get lightSpeedEtherTip =>
      'The speed of light is relative to a preferred global frame.';

  @override
  String get lightSpeedEmitter => 'Use Emitter Speed';

  @override
  String get lightSpeedEmitterTip =>
      'The speed of light is relative to its emitter.';

  @override
  String get toolSelect => 'Select';

  @override
  String get toolAdd => 'Add';

  @override
  String get drawTypeEvent => 'Event';

  @override
  String get drawTypeInstant => 'Instant';

  @override
  String get drawTypeCone => 'Light Cone';

  @override
  String get drawTypeClock => 'Clock';

  @override
  String get drawTypePerson => 'Person';

  @override
  String get drawTypeTrain => 'Train';

  @override
  String get drawTypeBarn => 'Barn';

  @override
  String get drawTypeFlag => 'Flag';

  @override
  String get time => 'Time';

  @override
  String get velocity => 'Velocity';

  @override
  String get unsavedSceneTitle => 'Unsaved Scene';

  @override
  String get unsavedSceneBody1 => 'The drawing has been modified.';

  @override
  String get unsavedSceneBody2 => 'Would you like to save it?';

  @override
  String get confirmPropertiesTitle => 'Confirm Properties Before Saving';

  @override
  String get tutorialCompletedTitle => 'Tutorial Completed!';

  @override
  String tutorialCompletedMessage(String title) {
    return 'Great job! You have completed all steps in $title. You can now continue playing with the scene and save your result.';
  }

  @override
  String get tutorialFinishKeepScene => 'Finish (Keep Scene)';

  @override
  String get tutorialDoItForMe => 'Do it for me';

  @override
  String get tutorialBack => 'Back';

  @override
  String get tutorialContinue => 'Continue';

  @override
  String get tutorialFinish => 'Finish';

  @override
  String tutorialStepCounter(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get helpDocumentationAndGuides => 'Documentation & Guides';

  @override
  String get helpUserGuides => 'User Guides';

  @override
  String get helpAbout => 'About Spacetime';

  @override
  String get helpPrivacy => 'Privacy Policy';

  @override
  String get helpTerms => 'Terms of Service';

  @override
  String get helpOverview => 'Overview';

  @override
  String get helpControls => 'Toolbar and Sliders';

  @override
  String get helpObjects => 'Spacetime Objects';

  @override
  String get helpTransformations => 'Relativistic Transformations';

  @override
  String get helpFiles => 'File Management';

  @override
  String get helpReadme => 'Readme';

  @override
  String get helpDeveloperGuide => 'Developer Guide';

  @override
  String get helpProjectPlan => 'Project Plan';

  @override
  String get themeMode => 'Theme';

  @override
  String get systemTheme => 'System Theme';

  @override
  String get lightTheme => 'Light Theme';

  @override
  String get darkTheme => 'Dark Theme';

  @override
  String get semanticsLanguageSwitcher => 'Select application language';

  @override
  String get semanticsDrawerOpen => 'Open navigation drawer';

  @override
  String get semanticsDrawerClose => 'Close navigation drawer';

  @override
  String get semanticsTimeSlider => 'Adjust simulation time';

  @override
  String get semanticsVelocitySlider =>
      'Adjust observer reference frame velocity';

  @override
  String get semanticsSpacetimeCanvas => 'Spacetime Minkowski diagram canvas';

  @override
  String get semanticsObserverCanvas => 'Observer side view canvas';
}
