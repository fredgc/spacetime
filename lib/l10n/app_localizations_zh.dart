// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '时空图绘制工具';

  @override
  String get language => '语言';

  @override
  String get systemDefault => '跟随系统';

  @override
  String get settings => '设置';

  @override
  String get settingsTitle => '设置';

  @override
  String get initializingSettings => '正在初始化设置...';

  @override
  String get helpOptions => '帮助选项';

  @override
  String get aboutSpacetime => '关于 Spacetime';

  @override
  String get helpAndUserGuides => '帮助与用户指南';

  @override
  String get developerDocs => '开发者文档';

  @override
  String get close => '关闭';

  @override
  String get cancel => '取消';

  @override
  String get save => '保存';

  @override
  String get saveAs => '另存为...';

  @override
  String get discard => '放弃修改';

  @override
  String get ok => '确定';

  @override
  String get title => '标题';

  @override
  String get description => '描述';

  @override
  String get objectName => '对象名称';

  @override
  String get menuFile => '文件';

  @override
  String get menuTutorials => '教程';

  @override
  String get menuEdit => '编辑';

  @override
  String get menuView => '视图';

  @override
  String get menuNew => '新建';

  @override
  String get menuOpen => '打开';

  @override
  String get menuReload => '重新加载';

  @override
  String get menuSave => '保存';

  @override
  String get menuSaveAs => '另存为';

  @override
  String get menuEditDescription => '编辑描述';

  @override
  String get menuShare => '分享';

  @override
  String get menuLogout => '登出';

  @override
  String get menuUndo => '撤销';

  @override
  String get menuRedo => '重做';

  @override
  String get menuCut => '剪切';

  @override
  String get menuCopy => '复制';

  @override
  String get menuPaste => '粘贴';

  @override
  String get menuDelete => '删除';

  @override
  String get menuFitScene => '适应画布';

  @override
  String get lightSpeedLorentz => '使用洛伦兹变换';

  @override
  String get lightSpeedLorentzTip => '光速在所有参考系中恒定不变。';

  @override
  String get lightSpeedEther => '使用以太假说';

  @override
  String get lightSpeedEtherTip => '光速仅相对于特选的绝对静止全局参考系恒定。';

  @override
  String get lightSpeedEmitter => '使用发射源速度';

  @override
  String get lightSpeedEmitterTip => '光速相对于发射光源的物体是相对的。';

  @override
  String get toolSelect => '选择';

  @override
  String get toolAdd => '添加';

  @override
  String get drawTypeEvent => '事件';

  @override
  String get drawTypeInstant => '瞬时面';

  @override
  String get drawTypeCone => '光锥';

  @override
  String get drawTypeClock => '时钟';

  @override
  String get drawTypePerson => '观察者';

  @override
  String get drawTypeTrain => '列车';

  @override
  String get drawTypeBarn => '车库';

  @override
  String get drawTypeFlag => '旗帜';

  @override
  String get time => '时间';

  @override
  String get velocity => '速度';

  @override
  String get unsavedSceneTitle => '未保存的场景';

  @override
  String get unsavedSceneBody1 => '图表已修改。';

  @override
  String get unsavedSceneBody2 => '是否保存更改？';

  @override
  String get confirmPropertiesTitle => '保存前确认属性';

  @override
  String get tutorialCompletedTitle => '教程已完成！';

  @override
  String tutorialCompletedMessage(String title) {
    return '太棒了！您已完成“$title”中的所有步骤。您现在可以继续自由探索该场景并保存您的成果。';
  }

  @override
  String get tutorialFinishKeepScene => '完成（保留当前场景）';

  @override
  String get tutorialDoItForMe => '帮我完成';

  @override
  String get tutorialBack => '返回';

  @override
  String get tutorialContinue => '继续';

  @override
  String get tutorialFinish => '完成';

  @override
  String tutorialStepCounter(int current, int total) {
    return '第 $current 步，共 $total 步';
  }

  @override
  String get helpDocumentationAndGuides => '文档与指南';

  @override
  String get helpUserGuides => '用户指南';

  @override
  String get helpAbout => '关于 Spacetime';

  @override
  String get helpPrivacy => '隐私政策';

  @override
  String get helpTerms => '服务条款';

  @override
  String get helpOverview => '概述';

  @override
  String get helpControls => '工具栏与滑块';

  @override
  String get helpObjects => '时空对象';

  @override
  String get helpTransformations => '相对论变换';

  @override
  String get helpFiles => '文件管理';

  @override
  String get helpReadme => '自述文件';

  @override
  String get helpDeveloperGuide => '开发者指南';

  @override
  String get helpProjectPlan => '项目计划';

  @override
  String get themeMode => '主题';

  @override
  String get systemTheme => '跟随系统';

  @override
  String get lightTheme => '浅色模式';

  @override
  String get darkTheme => '深色模式';

  @override
  String get semanticsLanguageSwitcher => '选择应用程序语言';

  @override
  String get semanticsDrawerOpen => '打开导航菜单';

  @override
  String get semanticsDrawerClose => '关闭导航菜单';

  @override
  String get semanticsTimeSlider => '调节模拟时间';

  @override
  String get semanticsVelocitySlider => '调节观察者参考系速度';

  @override
  String get semanticsSpacetimeCanvas => '闵可夫斯基时空图画布';

  @override
  String get semanticsObserverCanvas => '观察者侧视图画布';
}
