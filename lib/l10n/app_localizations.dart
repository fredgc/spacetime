import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_lt.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('en', 'GB'),
    Locale('es'),
    Locale('fr'),
    Locale('ja'),
    Locale('lt'),
    Locale('pt'),
    Locale('zh'),
  ];

  /// Application title displayed in browser tabs and headers
  ///
  /// In en, this message translates to:
  /// **'Spacetime Drawing Tool'**
  String get appTitle;

  /// Tooltip and label for language selector
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Option to use system default language
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// Settings label and tooltip
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Title of settings screen
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Message shown while settings load
  ///
  /// In en, this message translates to:
  /// **'Initializing Settings...'**
  String get initializingSettings;

  /// Tooltip for help menu button
  ///
  /// In en, this message translates to:
  /// **'Help Options'**
  String get helpOptions;

  /// Help menu item for about dialog
  ///
  /// In en, this message translates to:
  /// **'About Spacetime'**
  String get aboutSpacetime;

  /// Help menu item for documentation
  ///
  /// In en, this message translates to:
  /// **'Help & User Guides'**
  String get helpAndUserGuides;

  /// Help menu item for developer documentation
  ///
  /// In en, this message translates to:
  /// **'Developer Docs'**
  String get developerDocs;

  /// Close button label
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Save button label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Save As button label
  ///
  /// In en, this message translates to:
  /// **'Save As...'**
  String get saveAs;

  /// Discard button label
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// OK button label
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Label for title field
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// Label for description field
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Label for object name input
  ///
  /// In en, this message translates to:
  /// **'Object Name'**
  String get objectName;

  /// File menu title
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get menuFile;

  /// Tutorials menu title
  ///
  /// In en, this message translates to:
  /// **'Tutorials'**
  String get menuTutorials;

  /// Edit menu title
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get menuEdit;

  /// View menu title
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get menuView;

  /// New file menu item
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get menuNew;

  /// Open file menu item
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get menuOpen;

  /// Reload file menu item
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get menuReload;

  /// Save file menu item
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get menuSave;

  /// Save As menu item
  ///
  /// In en, this message translates to:
  /// **'Save As'**
  String get menuSaveAs;

  /// Edit Description menu item
  ///
  /// In en, this message translates to:
  /// **'Edit Description'**
  String get menuEditDescription;

  /// Share diagram menu item
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get menuShare;

  /// Log Out menu item
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get menuLogout;

  /// Undo menu item
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get menuUndo;

  /// Redo menu item
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get menuRedo;

  /// Cut menu item
  ///
  /// In en, this message translates to:
  /// **'Cut'**
  String get menuCut;

  /// Copy menu item
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get menuCopy;

  /// Paste menu item
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get menuPaste;

  /// Delete menu item
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get menuDelete;

  /// Fit scene viewport menu item
  ///
  /// In en, this message translates to:
  /// **'Fit Scene'**
  String get menuFitScene;

  /// Option for Lorentz transformation
  ///
  /// In en, this message translates to:
  /// **'Use Lorentz'**
  String get lightSpeedLorentz;

  /// Tooltip for Lorentz transformation
  ///
  /// In en, this message translates to:
  /// **'The speed of light is constant.'**
  String get lightSpeedLorentzTip;

  /// Option for Ether hypothesis
  ///
  /// In en, this message translates to:
  /// **'Use Ether'**
  String get lightSpeedEther;

  /// Tooltip for Ether hypothesis
  ///
  /// In en, this message translates to:
  /// **'The speed of light is relative to a preferred global frame.'**
  String get lightSpeedEtherTip;

  /// Option for Emitter speed hypothesis
  ///
  /// In en, this message translates to:
  /// **'Use Emitter Speed'**
  String get lightSpeedEmitter;

  /// Tooltip for Emitter speed hypothesis
  ///
  /// In en, this message translates to:
  /// **'The speed of light is relative to its emitter.'**
  String get lightSpeedEmitterTip;

  /// Select tool name
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get toolSelect;

  /// Add tool name
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get toolAdd;

  /// Event drawable type
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get drawTypeEvent;

  /// Instant drawable type
  ///
  /// In en, this message translates to:
  /// **'Instant'**
  String get drawTypeInstant;

  /// Light cone drawable type
  ///
  /// In en, this message translates to:
  /// **'Light Cone'**
  String get drawTypeCone;

  /// Clock drawable type
  ///
  /// In en, this message translates to:
  /// **'Clock'**
  String get drawTypeClock;

  /// Person drawable type
  ///
  /// In en, this message translates to:
  /// **'Person'**
  String get drawTypePerson;

  /// Train drawable type
  ///
  /// In en, this message translates to:
  /// **'Train'**
  String get drawTypeTrain;

  /// Barn drawable type
  ///
  /// In en, this message translates to:
  /// **'Barn'**
  String get drawTypeBarn;

  /// Flag drawable type
  ///
  /// In en, this message translates to:
  /// **'Flag'**
  String get drawTypeFlag;

  /// Time slider label
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// Velocity slider label
  ///
  /// In en, this message translates to:
  /// **'Velocity'**
  String get velocity;

  /// Title of unsaved changes dialog
  ///
  /// In en, this message translates to:
  /// **'Unsaved Scene'**
  String get unsavedSceneTitle;

  /// First line of unsaved changes dialog
  ///
  /// In en, this message translates to:
  /// **'The drawing has been modified.'**
  String get unsavedSceneBody1;

  /// Second line of unsaved changes dialog
  ///
  /// In en, this message translates to:
  /// **'Would you like to save it?'**
  String get unsavedSceneBody2;

  /// Title of save properties confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Confirm Properties Before Saving'**
  String get confirmPropertiesTitle;

  /// Title displayed when tutorial completes
  ///
  /// In en, this message translates to:
  /// **'Tutorial Completed!'**
  String get tutorialCompletedTitle;

  /// Message shown when tutorial completes
  ///
  /// In en, this message translates to:
  /// **'Great job! You have completed all steps in {title}. You can now continue playing with the scene and save your result.'**
  String tutorialCompletedMessage(String title);

  /// Button to finish tutorial while keeping current scene
  ///
  /// In en, this message translates to:
  /// **'Finish (Keep Scene)'**
  String get tutorialFinishKeepScene;

  /// Button to auto-complete current tutorial step
  ///
  /// In en, this message translates to:
  /// **'Do it for me'**
  String get tutorialDoItForMe;

  /// Button to go back in tutorial
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get tutorialBack;

  /// Button to advance to next tutorial step
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get tutorialContinue;

  /// Button to finish final tutorial step
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get tutorialFinish;

  /// Step progress indicator in tutorial card
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String tutorialStepCounter(int current, int total);

  /// Header in help sidebar
  ///
  /// In en, this message translates to:
  /// **'Documentation & Guides'**
  String get helpDocumentationAndGuides;

  /// Section header for user guides in help
  ///
  /// In en, this message translates to:
  /// **'User Guides'**
  String get helpUserGuides;

  /// Help drawer item for About page
  ///
  /// In en, this message translates to:
  /// **'About Spacetime'**
  String get helpAbout;

  /// Help drawer item for Privacy Policy
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get helpPrivacy;

  /// Help drawer item for Terms of Service
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get helpTerms;

  /// Help drawer item for Overview page
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get helpOverview;

  /// Help drawer item for Toolbar and Sliders
  ///
  /// In en, this message translates to:
  /// **'Toolbar and Sliders'**
  String get helpControls;

  /// Help drawer item for Spacetime Objects
  ///
  /// In en, this message translates to:
  /// **'Spacetime Objects'**
  String get helpObjects;

  /// Help drawer item for Relativistic Transformations
  ///
  /// In en, this message translates to:
  /// **'Relativistic Transformations'**
  String get helpTransformations;

  /// Help drawer item for File Management
  ///
  /// In en, this message translates to:
  /// **'File Management'**
  String get helpFiles;

  /// Help drawer item for Readme
  ///
  /// In en, this message translates to:
  /// **'Readme'**
  String get helpReadme;

  /// Help drawer item for Developer Guide
  ///
  /// In en, this message translates to:
  /// **'Developer Guide'**
  String get helpDeveloperGuide;

  /// Help drawer item for Project Plan
  ///
  /// In en, this message translates to:
  /// **'Project Plan'**
  String get helpProjectPlan;

  /// Settings label for theme selection
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeMode;

  /// Option for system theme
  ///
  /// In en, this message translates to:
  /// **'System Theme'**
  String get systemTheme;

  /// Option for light theme
  ///
  /// In en, this message translates to:
  /// **'Light Theme'**
  String get lightTheme;

  /// Option for dark theme
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get darkTheme;

  /// Accessibility label for language switcher popup button
  ///
  /// In en, this message translates to:
  /// **'Select application language'**
  String get semanticsLanguageSwitcher;

  /// Accessibility label for open drawer button
  ///
  /// In en, this message translates to:
  /// **'Open navigation drawer'**
  String get semanticsDrawerOpen;

  /// Accessibility label for close drawer button
  ///
  /// In en, this message translates to:
  /// **'Close navigation drawer'**
  String get semanticsDrawerClose;

  /// Accessibility label for time slider
  ///
  /// In en, this message translates to:
  /// **'Adjust simulation time'**
  String get semanticsTimeSlider;

  /// Accessibility label for velocity slider
  ///
  /// In en, this message translates to:
  /// **'Adjust observer reference frame velocity'**
  String get semanticsVelocitySlider;

  /// Accessibility label for top spacetime canvas
  ///
  /// In en, this message translates to:
  /// **'Spacetime Minkowski diagram canvas'**
  String get semanticsSpacetimeCanvas;

  /// Accessibility label for bottom observer canvas
  ///
  /// In en, this message translates to:
  /// **'Observer side view canvas'**
  String get semanticsObserverCanvas;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'ja',
    'lt',
    'pt',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'en':
      {
        switch (locale.countryCode) {
          case 'GB':
            return AppLocalizationsEnGb();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
    case 'lt':
      return AppLocalizationsLt();
    case 'pt':
      return AppLocalizationsPt();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
