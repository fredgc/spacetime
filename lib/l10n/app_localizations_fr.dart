// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Outil de dessin Spacetime';

  @override
  String get language => 'Langue';

  @override
  String get systemDefault => 'Par défaut du système';

  @override
  String get settings => 'Paramètres';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get initializingSettings => 'Initialisation des paramètres...';

  @override
  String get helpOptions => 'Options d\'aide';

  @override
  String get aboutSpacetime => 'À propos de Spacetime';

  @override
  String get helpAndUserGuides => 'Aide et guides d\'utilisation';

  @override
  String get developerDocs => 'Documentation développeur';

  @override
  String get close => 'Fermer';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get saveAs => 'Enregistrer sous...';

  @override
  String get discard => 'Ne pas enregistrer';

  @override
  String get ok => 'OK';

  @override
  String get title => 'Titre';

  @override
  String get description => 'Description';

  @override
  String get objectName => 'Nom de l\'objet';

  @override
  String get menuFile => 'Fichier';

  @override
  String get menuTutorials => 'Tutoriels';

  @override
  String get menuEdit => 'Édition';

  @override
  String get menuView => 'Affichage';

  @override
  String get menuNew => 'Nouveau';

  @override
  String get menuOpen => 'Ouvrir';

  @override
  String get menuReload => 'Recharger';

  @override
  String get menuSave => 'Enregistrer';

  @override
  String get menuSaveAs => 'Enregistrer sous';

  @override
  String get menuEditDescription => 'Modifier la description';

  @override
  String get menuShare => 'Partager';

  @override
  String get menuLogout => 'Déconnexion';

  @override
  String get menuUndo => 'Annuler';

  @override
  String get menuRedo => 'Rétablir';

  @override
  String get menuCut => 'Couper';

  @override
  String get menuCopy => 'Copier';

  @override
  String get menuPaste => 'Coller';

  @override
  String get menuDelete => 'Supprimer';

  @override
  String get menuFitScene => 'Ajuster la scène';

  @override
  String get lightSpeedLorentz => 'Transformation de Lorentz';

  @override
  String get lightSpeedLorentzTip => 'La vitesse de la lumière est constante.';

  @override
  String get lightSpeedEther => 'Hypothèse de l\'éther';

  @override
  String get lightSpeedEtherTip =>
      'La vitesse de la lumière est relative à un référentiel global privilégié.';

  @override
  String get lightSpeedEmitter => 'Vitesse de l\'émetteur';

  @override
  String get lightSpeedEmitterTip =>
      'La vitesse de la lumière est relative à son émetteur.';

  @override
  String get toolSelect => 'Sélectionner';

  @override
  String get toolAdd => 'Ajouter';

  @override
  String get drawTypeEvent => 'Événement';

  @override
  String get drawTypeInstant => 'Instant';

  @override
  String get drawTypeCone => 'Cône de lumière';

  @override
  String get drawTypeClock => 'Horloge';

  @override
  String get drawTypePerson => 'Personne';

  @override
  String get drawTypeTrain => 'Train';

  @override
  String get drawTypeBarn => 'Grange';

  @override
  String get drawTypeFlag => 'Drapeau';

  @override
  String get time => 'Temps';

  @override
  String get velocity => 'Vitesse';

  @override
  String get unsavedSceneTitle => 'Scène non enregistrée';

  @override
  String get unsavedSceneBody1 => 'Le dessin a été modifié.';

  @override
  String get unsavedSceneBody2 => 'Souhaitez-vous l\'enregistrer ?';

  @override
  String get confirmPropertiesTitle =>
      'Confirmer les propriétés avant d\'enregistrer';

  @override
  String get tutorialCompletedTitle => 'Tutoriel terminé !';

  @override
  String tutorialCompletedMessage(String title) {
    return 'Félicitations ! Vous avez terminé toutes les étapes de $title. Vous pouvez maintenant continuer à explorer la scène et enregistrer votre résultat.';
  }

  @override
  String get tutorialFinishKeepScene => 'Terminer (conserver la scène)';

  @override
  String get tutorialDoItForMe => 'Faire pour moi';

  @override
  String get tutorialBack => 'Retour';

  @override
  String get tutorialContinue => 'Continuer';

  @override
  String get tutorialFinish => 'Terminer';

  @override
  String tutorialStepCounter(int current, int total) {
    return 'Étape $current sur $total';
  }

  @override
  String get helpDocumentationAndGuides => 'Documentation et guides';

  @override
  String get helpUserGuides => 'Guides d\'utilisation';

  @override
  String get helpAbout => 'À propos de Spacetime';

  @override
  String get helpPrivacy => 'Politique de confidentialité';

  @override
  String get helpTerms => 'Conditions d\'utilisation';

  @override
  String get helpOverview => 'Aperçu';

  @override
  String get helpControls => 'Barre d\'outils et curseurs';

  @override
  String get helpObjects => 'Objets de l\'espace-temps';

  @override
  String get helpTransformations => 'Transformations relativistes';

  @override
  String get helpFiles => 'Gestion des fichiers';

  @override
  String get helpReadme => 'Lisez-moi';

  @override
  String get helpDeveloperGuide => 'Guide du développeur';

  @override
  String get helpProjectPlan => 'Plan du projet';

  @override
  String get themeMode => 'Thème';

  @override
  String get systemTheme => 'Thème du système';

  @override
  String get lightTheme => 'Thème clair';

  @override
  String get darkTheme => 'Thème sombre';

  @override
  String get semanticsLanguageSwitcher =>
      'Sélectionner la langue de l\'application';

  @override
  String get semanticsDrawerOpen => 'Ouvrir le menu de navigation';

  @override
  String get semanticsDrawerClose => 'Fermer le menu de navigation';

  @override
  String get semanticsTimeSlider => 'Ajuster le temps de simulation';

  @override
  String get semanticsVelocitySlider =>
      'Ajuster la vitesse du référentiel de l\'observateur';

  @override
  String get semanticsSpacetimeCanvas =>
      'Canevas du diagramme d\'espace-temps de Minkowski';

  @override
  String get semanticsObserverCanvas =>
      'Canevas de la vue latérale de l\'observateur';
}
