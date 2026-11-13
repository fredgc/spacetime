// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => '時空図作図ツール';

  @override
  String get language => '言語';

  @override
  String get systemDefault => 'システムのデフォルト';

  @override
  String get settings => '設定';

  @override
  String get settingsTitle => '設定';

  @override
  String get initializingSettings => '設定を初期化中...';

  @override
  String get helpOptions => 'ヘルプオプション';

  @override
  String get aboutSpacetime => 'Spacetime について';

  @override
  String get helpAndUserGuides => 'ヘルプとユーザーガイド';

  @override
  String get developerDocs => '開発者ドキュメント';

  @override
  String get close => '閉じる';

  @override
  String get cancel => 'キャンセル';

  @override
  String get save => '保存';

  @override
  String get saveAs => '名前を付けて保存...';

  @override
  String get discard => '変更を破棄';

  @override
  String get ok => 'OK';

  @override
  String get title => 'タイトル';

  @override
  String get description => '説明';

  @override
  String get objectName => 'オブジェクト名';

  @override
  String get menuFile => 'ファイル';

  @override
  String get menuTutorials => 'チュートリアル';

  @override
  String get menuEdit => '編集';

  @override
  String get menuView => '表示';

  @override
  String get menuNew => '新規作成';

  @override
  String get menuOpen => '開く';

  @override
  String get menuReload => '再読み込み';

  @override
  String get menuSave => '保存';

  @override
  String get menuSaveAs => '名前を付けて保存';

  @override
  String get menuEditDescription => '説明を編集';

  @override
  String get menuShare => '共有';

  @override
  String get menuLogout => 'ログアウト';

  @override
  String get menuUndo => '元に戻す';

  @override
  String get menuRedo => 'やり直し';

  @override
  String get menuCut => '切り取り';

  @override
  String get menuCopy => 'コピー';

  @override
  String get menuPaste => '貼り付け';

  @override
  String get menuDelete => '削除';

  @override
  String get menuFitScene => 'シーンに合わせる';

  @override
  String get lightSpeedLorentz => 'ローレンツ変換を使用';

  @override
  String get lightSpeedLorentzTip => '光速度はすべての基準系で不変です。';

  @override
  String get lightSpeedEther => 'エーテル仮説を使用';

  @override
  String get lightSpeedEtherTip => '光速度は特定の静止大域系に対してのみ相対的です。';

  @override
  String get lightSpeedEmitter => '光源速度を使用';

  @override
  String get lightSpeedEmitterTip => '光速度は光を発した光源に対して相対的です。';

  @override
  String get toolSelect => '選択';

  @override
  String get toolAdd => '追加';

  @override
  String get drawTypeEvent => '事象';

  @override
  String get drawTypeInstant => '同時面';

  @override
  String get drawTypeCone => '光円錐';

  @override
  String get drawTypeClock => '時計';

  @override
  String get drawTypePerson => '観測者';

  @override
  String get drawTypeTrain => '列車';

  @override
  String get drawTypeBarn => '車庫';

  @override
  String get drawTypeFlag => '旗';

  @override
  String get time => '時間';

  @override
  String get velocity => '速度';

  @override
  String get unsavedSceneTitle => '未保存のシーン';

  @override
  String get unsavedSceneBody1 => '図面が変更されています。';

  @override
  String get unsavedSceneBody2 => '保存しますか？';

  @override
  String get confirmPropertiesTitle => '保存前のプロパティ確認';

  @override
  String get tutorialCompletedTitle => 'チュートリアル完了！';

  @override
  String tutorialCompletedMessage(String title) {
    return 'おめでとうございます！「$title」の全ステップを完了しました。このままシーンを動かして実験したり、結果を保存できます。';
  }

  @override
  String get tutorialFinishKeepScene => '完了（現在のシーンを保持）';

  @override
  String get tutorialDoItForMe => '自動で実行';

  @override
  String get tutorialBack => '戻る';

  @override
  String get tutorialContinue => '次へ';

  @override
  String get tutorialFinish => '完了';

  @override
  String tutorialStepCounter(int current, int total) {
    return 'ステップ $current / $total';
  }

  @override
  String get helpDocumentationAndGuides => 'ドキュメントとガイド';

  @override
  String get helpUserGuides => 'ユーザーガイド';

  @override
  String get helpAbout => 'Spacetime について';

  @override
  String get helpPrivacy => 'プライバシーポリシー';

  @override
  String get helpTerms => '利用規約';

  @override
  String get helpOverview => '概要';

  @override
  String get helpControls => 'ツールバーとスライダー';

  @override
  String get helpObjects => '時空オブジェクト';

  @override
  String get helpTransformations => '相対論的変換';

  @override
  String get helpFiles => 'ファイル管理';

  @override
  String get helpReadme => 'Readme';

  @override
  String get helpDeveloperGuide => '開発者ガイド';

  @override
  String get helpProjectPlan => 'プロジェクト計画';

  @override
  String get themeMode => 'テーマ';

  @override
  String get systemTheme => 'システムのデフォルト';

  @override
  String get lightTheme => 'ライトテーマ';

  @override
  String get darkTheme => 'ダークテーマ';

  @override
  String get semanticsLanguageSwitcher => 'アプリケーション言語を選択';

  @override
  String get semanticsDrawerOpen => 'ナビゲーションメニューを開く';

  @override
  String get semanticsDrawerClose => 'ナビゲーションメニューを閉じる';

  @override
  String get semanticsTimeSlider => 'シミュレーション時間を調整';

  @override
  String get semanticsVelocitySlider => '観測者基準系の速度を調整';

  @override
  String get semanticsSpacetimeCanvas => 'ミンコフスキー時空図キャンバス';

  @override
  String get semanticsObserverCanvas => '観測者側面図キャンバス';
}
