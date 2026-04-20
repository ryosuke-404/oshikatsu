import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'models/billing_model.dart';
import 'models/goods_model.dart';
import 'models/mission_model.dart';
import 'models/oshi_model.dart';
import 'models/record_model.dart';
import 'models/schedule_models.dart';
import 'models/series_model.dart';
import 'services/theme_provider.dart';
import 'providers/ad_provider.dart';

/// アプリケーションのエントリーポイント（最初に実行される関数）
Future<void> main() async {
  try {
    // --- 1. Flutterフレームワークの初期化 ---
    WidgetsFlutterBinding.ensureInitialized();
    // メモリ不足対策: 画像キャッシュの上限を調整 (例: 100MB)
    PaintingBinding.instance.imageCache.maximumSizeBytes = 1024 * 1024 * 100;
    await EasyLocalization.ensureInitialized();

    // --- 1.1. Google Mobile Ads SDKの初期化 ---
    // SDKの初期化を待ってから広告をロードするのが推奨されます
    await MobileAds.instance.initialize();
    // リワード広告の事前読み込みを開始
    // 【メモリ対策】スプラッシュ動画再生中のOOM(メモリ不足)を防ぐため、起動直後の広告ロードを停止します
    // RewardAdService().loadAd();

    // --- 2. Hiveデータベースの初期化 ---
    await Hive.initFlutter();

    // --- 3. Hiveアダプターの登録 ---
    // typeIdが重複しないように再割り当てしました。

    // ミッション関連 (typeId: 20-29)
    Hive.registerAdapter(IconDataAdapter()); // typeId: 20
    Hive.registerAdapter(MissionAdapter()); // typeId: 21
    Hive.registerAdapter(DepositAdapter()); // typeId: 22

    // スケジュール・イベント関連 (typeId: 30-39)
    Hive.registerAdapter(EventAdapter()); // typeId: 30
    Hive.registerAdapter(ItineraryAdapter()); // typeId: 31
    Hive.registerAdapter(TodoItemAdapter()); // typeId: 32 // 追加
    Hive.registerAdapter(EventCategoryAdapter()); // typeId: 33

    // 記録関連 (typeId: 40-49)
    Hive.registerAdapter(RecordAdapter()); // typeId: 40
    Hive.registerAdapter(RecordCategoryAdapter()); // typeId: 41

    // 推し関連 (typeId: 50-59)
    Hive.registerAdapter(OshiAdapter()); // typeId: 50
    Hive.registerAdapter(OshiLevelAdapter()); // typeId: 51

    // 課金関連 (typeId: 100-109)
    Hive.registerAdapter(BillingRecordAdapter()); // typeId: 100
    Hive.registerAdapter(BillingCategoryAdapter()); // typeId: 101
    Hive.registerAdapter(PaymentMethodAdapter()); // typeId: 102

    // グッズ関連 (typeId: 110-119)
    Hive.registerAdapter(GoodsAdapter()); // typeId: 110

    // シリーズ関連 (typeId: 120-129)
    Hive.registerAdapter(SeriesAdapter()); // typeId: 120

    // --- 4. Hive Boxを開く ---
    await Hive.openBox<BillingRecord>('billing_records');
    await Hive.openBox<Goods>('goods');
    await Hive.openBox<Mission>('missions');
    await Hive.openBox<Event>('events');
    await Hive.openBox<Itinerary>('itineraries');
    await Hive.openBox<Oshi>('oshis');
    await Hive.openBox<Record>('records');
    await Hive.openBox<Series>('series');
    await Hive.openBox('settings');
    await Hive.openBox<String>('custom_tags');

    // --- 4.1. データ移行と初期化処理 ---
    // 既存データの構造変更や初期データの投入を安全に行うための処理
    await _performAppMigration();

    // --- 5. 日付フォーマットの初期化 ---
    await initializeDateFormatting('ja_JP');

    // --- 6. アプリケーションの実行 ---
    runApp(
      EasyLocalization(
        supportedLocales: const [
          Locale('ja'),
          Locale('en'),
          Locale('zh', 'CN'),
          Locale('zh', 'TW'),
          Locale('ko'),
          Locale('es'),
          Locale('fr'),
          Locale('de'),
          Locale('pt', 'BR'),
          Locale('ru'),
          Locale('hi'),
          Locale('ar'),
          Locale('id'),
          Locale('ms'),
          Locale('th'),
          Locale('vi'),
          Locale('it'),
          Locale('nl'),
          Locale('pl'),
          Locale('tr'),
        ],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => ThemeProvider()),
            ChangeNotifierProvider(create: (context) => AdProvider()),
          ],
          child: const OshikatsuApp(),
        ),
      ),
    );
  } catch (e, stacktrace) {
    // エラーハンドリング: アプリ起動時の問題をデバッグしやすくします
    print('##### アプリケーションの起動に失敗しました #####');
    print('エラー内容: $e');
    print('スタックトレース: $stacktrace');
  }
}

/// アプリのバージョンアップに伴うデータ移行処理を行う関数
/// 既存ユーザーのデータを壊さずに新しいデータ構造へ移行するために使用します。
Future<void> _performAppMigration() async {
  final settingsBox = Hive.box('settings');

  // 現在のDBバージョンを取得（未設定の場合は0）
  final int currentDbVersion = settingsBox.get('db_version', defaultValue: 0);

  // 最新のDBバージョン（今後DB構造を変更するたびに、この数字を増やします）
  const int latestDbVersion = 1;

  if (currentDbVersion < latestDbVersion) {
    // --- バージョン 1 への移行処理 ---
    // Seriesデータの初期化・移行ロジック
    final seriesBox = Hive.box<Series>('series');
    if (seriesBox.isEmpty) {
      final goodsBox = Hive.box<Goods>('goods');
      final uniqueSeriesNames = goodsBox.values
          .map((g) => g.series)
          .where((s) => s != null && s.isNotEmpty)
          .toSet()
          .toList();

      for (var i = 0; i < uniqueSeriesNames.length; i++) {
        final seriesName = uniqueSeriesNames[i];
        if (seriesName != null) {
          seriesBox.add(Series(name: seriesName, order: i));
        }
      }
    }

    // 移行完了後、バージョンを更新して保存
    await settingsBox.put('db_version', latestDbVersion);
  }
}

/// アプリケーションのルートウィジェット
class OshikatsuApp extends StatelessWidget {
  const OshikatsuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          // 言語に応じてアプリの表示名を切り替えます
          onGenerateTitle: (context) {
            final lang = context.locale.languageCode;
            if (lang == 'ja') {
              return '推し活日記';
            } else if (lang == 'zh') {
              return '追星日记';
            } else if (lang == 'ko') {
              return '덕질 일기';
            } else if (lang == 'th') {
              return 'บันทึกติ่ง';
            } else if (lang == 'id') {
              return 'Catatan Bias';
            } else if (lang == 'es') {
              return 'Diario de Fandom';
            } else if (lang == 'fr') {
              return 'Journal de Fan';
            }
            return 'Fave Diary'; // 英語圏向けの親しみやすい名前（"推し" = "Fave"）
          },
          debugShowCheckedModeBanner: false,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          theme: themeProvider.themeData,
          home: const App(),
        );
      },
    );
  }
}
