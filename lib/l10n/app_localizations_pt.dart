// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Ferramenta de Desenho do Espaço-Tempo';

  @override
  String get language => 'Idioma';

  @override
  String get systemDefault => 'Padrão do Sistema';

  @override
  String get settings => 'Configurações';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get initializingSettings => 'Inicializando configurações...';

  @override
  String get helpOptions => 'Opções de Ajuda';

  @override
  String get aboutSpacetime => 'Sobre o Spacetime';

  @override
  String get helpAndUserGuides => 'Ajuda e Guias do Usuário';

  @override
  String get developerDocs => 'Documentação do Desenvolvedor';

  @override
  String get close => 'Fechar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Salvar';

  @override
  String get saveAs => 'Salvar como...';

  @override
  String get discard => 'Descartar';

  @override
  String get ok => 'OK';

  @override
  String get title => 'Título';

  @override
  String get description => 'Descrição';

  @override
  String get objectName => 'Nome do Objeto';

  @override
  String get menuFile => 'Arquivo';

  @override
  String get menuTutorials => 'Tutoriais';

  @override
  String get menuEdit => 'Editar';

  @override
  String get menuView => 'Exibir';

  @override
  String get menuNew => 'Novo';

  @override
  String get menuOpen => 'Abrir';

  @override
  String get menuReload => 'Recarregar';

  @override
  String get menuSave => 'Salvar';

  @override
  String get menuSaveAs => 'Salvar como';

  @override
  String get menuEditDescription => 'Editar Descrição';

  @override
  String get menuShare => 'Compartilhar';

  @override
  String get menuLogout => 'Sair';

  @override
  String get menuUndo => 'Desfazer';

  @override
  String get menuRedo => 'Refazer';

  @override
  String get menuCut => 'Recortar';

  @override
  String get menuCopy => 'Copiar';

  @override
  String get menuPaste => 'Colar';

  @override
  String get menuDelete => 'Excluir';

  @override
  String get menuFitScene => 'Ajustar Cena';

  @override
  String get lightSpeedLorentz => 'Usar Lorentz';

  @override
  String get lightSpeedLorentzTip => 'A velocidade da luz é constante.';

  @override
  String get lightSpeedEther => 'Usar Éter';

  @override
  String get lightSpeedEtherTip =>
      'A velocidade da luz é relativa a um referencial global preferencial.';

  @override
  String get lightSpeedEmitter => 'Usar Velocidade do Emissor';

  @override
  String get lightSpeedEmitterTip =>
      'A velocidade da luz é relativa ao seu emissor.';

  @override
  String get toolSelect => 'Selecionar';

  @override
  String get toolAdd => 'Adicionar';

  @override
  String get drawTypeEvent => 'Evento';

  @override
  String get drawTypeInstant => 'Instante';

  @override
  String get drawTypeCone => 'Cone de Luz';

  @override
  String get drawTypeClock => 'Relógio';

  @override
  String get drawTypePerson => 'Pessoa';

  @override
  String get drawTypeTrain => 'Trem';

  @override
  String get drawTypeBarn => 'Celeiro';

  @override
  String get drawTypeFlag => 'Bandeira';

  @override
  String get time => 'Tempo';

  @override
  String get velocity => 'Velocidade';

  @override
  String get unsavedSceneTitle => 'Cena Não Salva';

  @override
  String get unsavedSceneBody1 => 'O desenho foi modificado.';

  @override
  String get unsavedSceneBody2 => 'Deseja salvá-lo?';

  @override
  String get confirmPropertiesTitle => 'Confirmar Propriedades Antes de Salvar';

  @override
  String get tutorialCompletedTitle => 'Tutorial Concluído!';

  @override
  String tutorialCompletedMessage(String title) {
    return 'Ótimo trabalho! Você concluiu todas as etapas em $title. Agora você pode continuar explorando a cena e salvar seu resultado.';
  }

  @override
  String get tutorialFinishKeepScene => 'Concluir (Manter Cena)';

  @override
  String get tutorialDoItForMe => 'Fazer por mim';

  @override
  String get tutorialBack => 'Voltar';

  @override
  String get tutorialContinue => 'Continuar';

  @override
  String get tutorialFinish => 'Concluir';

  @override
  String tutorialStepCounter(int current, int total) {
    return 'Etapa $current de $total';
  }

  @override
  String get helpDocumentationAndGuides => 'Documentação e Guias';

  @override
  String get helpUserGuides => 'Guias do Usuário';

  @override
  String get helpAbout => 'Sobre o Spacetime';

  @override
  String get helpPrivacy => 'Política de Privacidade';

  @override
  String get helpTerms => 'Termos de Serviço';

  @override
  String get helpOverview => 'Visão Geral';

  @override
  String get helpControls => 'Barra de Ferramentas e Controles';

  @override
  String get helpObjects => 'Objetos do Espaço-Tempo';

  @override
  String get helpTransformations => 'Transformações Relativísticas';

  @override
  String get helpFiles => 'Gerenciamento de Arquivos';

  @override
  String get helpReadme => 'Leia-me';

  @override
  String get helpDeveloperGuide => 'Guia do Desenvolvedor';

  @override
  String get helpProjectPlan => 'Plano do Projeto';

  @override
  String get themeMode => 'Tema';

  @override
  String get systemTheme => 'Padrão do Sistema';

  @override
  String get lightTheme => 'Tema Claro';

  @override
  String get darkTheme => 'Tema Escuro';

  @override
  String get semanticsLanguageSwitcher => 'Selecionar idioma do aplicativo';

  @override
  String get semanticsDrawerOpen => 'Abrir menu de navegação';

  @override
  String get semanticsDrawerClose => 'Fechar menu de navegação';

  @override
  String get semanticsTimeSlider => 'Ajustar tempo da simulação';

  @override
  String get semanticsVelocitySlider =>
      'Ajustar velocidade do referencial do observador';

  @override
  String get semanticsSpacetimeCanvas =>
      'Tela do diagrama do espaço-tempo de Minkowski';

  @override
  String get semanticsObserverCanvas => 'Tela da visão lateral do observador';
}
