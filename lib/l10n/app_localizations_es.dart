// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Herramienta de Dibujo Spacetime';

  @override
  String get language => 'Idioma';

  @override
  String get systemDefault => 'Predeterminado del sistema';

  @override
  String get settings => 'Ajustes';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get initializingSettings => 'Inicializando ajustes...';

  @override
  String get helpOptions => 'Opciones de ayuda';

  @override
  String get aboutSpacetime => 'Acerca de Spacetime';

  @override
  String get helpAndUserGuides => 'Ayuda y guías de usuario';

  @override
  String get developerDocs => 'Documentación para desarrolladores';

  @override
  String get close => 'Cerrar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get saveAs => 'Guardar como...';

  @override
  String get discard => 'Descartar';

  @override
  String get ok => 'Aceptar';

  @override
  String get title => 'Título';

  @override
  String get description => 'Descripción';

  @override
  String get objectName => 'Nombre del objeto';

  @override
  String get menuFile => 'Archivo';

  @override
  String get menuTutorials => 'Tutoriales';

  @override
  String get menuEdit => 'Edición';

  @override
  String get menuView => 'Ver';

  @override
  String get menuNew => 'Nuevo';

  @override
  String get menuOpen => 'Abrir';

  @override
  String get menuReload => 'Recargar';

  @override
  String get menuSave => 'Guardar';

  @override
  String get menuSaveAs => 'Guardar como';

  @override
  String get menuEditDescription => 'Editar descripción';

  @override
  String get menuShare => 'Compartir';

  @override
  String get menuLogout => 'Cerrar sesión';

  @override
  String get menuUndo => 'Deshacer';

  @override
  String get menuRedo => 'Rehacer';

  @override
  String get menuCut => 'Cortar';

  @override
  String get menuCopy => 'Copiar';

  @override
  String get menuPaste => 'Pegar';

  @override
  String get menuDelete => 'Eliminar';

  @override
  String get menuFitScene => 'Ajustar escena';

  @override
  String get lightSpeedLorentz => 'Usar Lorentz';

  @override
  String get lightSpeedLorentzTip => 'La velocidad de la luz es constante.';

  @override
  String get lightSpeedEther => 'Usar éter';

  @override
  String get lightSpeedEtherTip =>
      'La velocidad de la luz es relativa a un sistema global preferente.';

  @override
  String get lightSpeedEmitter => 'Usar velocidad del emisor';

  @override
  String get lightSpeedEmitterTip =>
      'La velocidad de la luz es relativa a su emisor.';

  @override
  String get toolSelect => 'Seleccionar';

  @override
  String get toolAdd => 'Añadir';

  @override
  String get drawTypeEvent => 'Evento';

  @override
  String get drawTypeInstant => 'Instante';

  @override
  String get drawTypeCone => 'Cono de luz';

  @override
  String get drawTypeClock => 'Reloj';

  @override
  String get drawTypePerson => 'Persona';

  @override
  String get drawTypeTrain => 'Tren';

  @override
  String get drawTypeBarn => 'Granero';

  @override
  String get drawTypeFlag => 'Bandera';

  @override
  String get time => 'Tiempo';

  @override
  String get velocity => 'Velocidad';

  @override
  String get unsavedSceneTitle => 'Escena no guardada';

  @override
  String get unsavedSceneBody1 => 'El dibujo ha sido modificado.';

  @override
  String get unsavedSceneBody2 => '¿Desea guardarlo?';

  @override
  String get confirmPropertiesTitle => 'Confirmar propiedades antes de guardar';

  @override
  String get tutorialCompletedTitle => '¡Tutorial completado!';

  @override
  String tutorialCompletedMessage(String title) {
    return '¡Excelente trabajo! Ha completado todos los pasos en $title. Ahora puede seguir interactuando con la escena y guardar su resultado.';
  }

  @override
  String get tutorialFinishKeepScene => 'Finalizar (conservar escena)';

  @override
  String get tutorialDoItForMe => 'Hacerlo por mí';

  @override
  String get tutorialBack => 'Atrás';

  @override
  String get tutorialContinue => 'Continuar';

  @override
  String get tutorialFinish => 'Finalizar';

  @override
  String tutorialStepCounter(int current, int total) {
    return 'Paso $current de $total';
  }

  @override
  String get helpDocumentationAndGuides => 'Documentación y guías';

  @override
  String get helpUserGuides => 'Guías de usuario';

  @override
  String get helpAbout => 'Acerca de Spacetime';

  @override
  String get helpPrivacy => 'Política de privacidad';

  @override
  String get helpTerms => 'Términos de servicio';

  @override
  String get helpOverview => 'Descripción general';

  @override
  String get helpControls => 'Barra de herramientas y controles';

  @override
  String get helpObjects => 'Objetos del espaciotiempo';

  @override
  String get helpTransformations => 'Transformaciones relativistas';

  @override
  String get helpFiles => 'Gestión de archivos';

  @override
  String get helpReadme => 'Léame';

  @override
  String get helpDeveloperGuide => 'Guía para desarrolladores';

  @override
  String get helpProjectPlan => 'Plan del proyecto';

  @override
  String get themeMode => 'Tema';

  @override
  String get systemTheme => 'Tema del sistema';

  @override
  String get lightTheme => 'Tema claro';

  @override
  String get darkTheme => 'Tema oscuro';

  @override
  String get semanticsLanguageSwitcher => 'Seleccionar idioma de la aplicación';

  @override
  String get semanticsDrawerOpen => 'Abrir panel de navegación';

  @override
  String get semanticsDrawerClose => 'Cerrar panel de navegación';

  @override
  String get semanticsTimeSlider => 'Ajustar tiempo de simulación';

  @override
  String get semanticsVelocitySlider =>
      'Ajustar velocidad del sistema de referencia del observador';

  @override
  String get semanticsSpacetimeCanvas =>
      'Lienzo del diagrama de espaciotiempo de Minkowski';

  @override
  String get semanticsObserverCanvas =>
      'Lienzo de la vista lateral del observador';
}
