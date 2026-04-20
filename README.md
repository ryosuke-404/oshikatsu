# 推し活日記 (Oshikatu)

> 推し活をもっと楽しく、もっと丁寧に。  
> A cross-platform fan activity management app for idol and K-pop fans.

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web-lightgrey" />
  <img src="https://img.shields.io/badge/i18n-20%20Languages-success" />
  <img src="https://img.shields.io/badge/version-1.0.81-blue" />
</p>

---

## 概要 / Overview

**推し活日記**は、アイドル・K-POPファンが日常の推し活を記録・管理するためのクロスプラットフォームアプリです。

ライブ・イベント参加記録、グッズ管理、推し活費用の家計簿、スケジュール管理など、推し活に関するすべてをオールインワンで管理できます。オフラインファーストで設計されており、インターネット接続なしでも快適に使用できます。

**Oshikatu** is a cross-platform fan activity management app for idol and K-pop fans.  
Record concerts and events, manage merchandise, track spending, and organize schedules — all in one place.

---

## 主な機能 / Key Features

### 推し管理 / Oshi Management
- 複数の推しをプロフィール付きで登録・管理
- 推しレベル設定（最推し / 単推し / DD など）
- SNSリンク連携（Twitter / Instagram / TikTok / YouTube / Spotify / Apple Music など）
- テーマカラーのカスタマイズ

### 活動記録 / Activity Records
- ライブ・イベント・聖地巡礼・カフェ・グッズ購入など10種類以上のカテゴリ
- 写真・動画・住所・セットリスト・メモの記録
- 感情タグとレーティングで思い出を振り返り

### スケジュール管理 / Schedule Management
- インタラクティブなカレンダービュー
- 旅程表（イテナリー）の作成とToDoリスト
- 誕生日・リリース日などの繰り返しイベント対応

### グッズ管理 / Merchandise Management
- フォトブック・ブロマイド・CD/DVD・缶バッジ・アクスタなど13カテゴリ対応
- 所有済み / ウィッシュリスト の仕分け
- シリーズ管理・画像添付

### 推し活費用管理 / Expense Tracking
- チケット・グッズ・交通費・宿泊費など10以上のカテゴリで支出を記録
- 予算設定と予算超過アラート
- カテゴリ別・月別の支出グラフ（FL Chart 使用）
- 現金・カード・電子マネーなど支払い方法を記録

### ミッション / Goals
- 貯金目標の設定と進捗管理
- 期限付きの節約チャレンジ機能

---

## 技術スタック / Tech Stack

| カテゴリ | 技術 |
|---------|------|
| **Framework** | Flutter (Dart) |
| **State Management** | Provider |
| **Local Database** | Hive (NoSQL, offline-first) |
| **Localization** | Easy Localization (20言語対応) |
| **Charts** | FL Chart |
| **Maps** | Flutter Map + LatLong2 |
| **Media** | Image Picker, Video Player, YouTube Player |
| **Ads** | Google Mobile Ads |
| **Code Generation** | Build Runner + Hive Generator |
| **Networking** | HTTP |

---

## アーキテクチャ / Architecture

```
lib/
├── main.dart               # アプリ初期化・Hiveセットアップ・ローカライゼーション
├── app.dart                # ナビゲーション構造
├── models/                 # Hiveベースのデータモデル
│   ├── oshi_model.dart
│   ├── billing_model.dart
│   ├── goods_model.dart
│   ├── record_model.dart
│   ├── mission_model.dart
│   └── schedule_models.dart
├── screens/                # 画面レイヤー
│   ├── home_screen.dart
│   ├── record/
│   ├── schedule/
│   ├── management/
│   └── settings/
├── widgets/                # 再利用可能UIコンポーネント
├── services/               # ビジネスロジック
│   ├── theme_provider.dart
│   ├── reward_ad_service.dart
│   └── oshikatsu_level_service.dart
├── providers/              # 状態管理
└── utils/                  # ユーティリティ
```

**設計方針:**
- **オフラインファースト**: Hive によるローカルDB設計。ネット接続不要
- **関心の分離**: Screen / Service / Provider / Model の明確な責務分割
- **データマイグレーション**: バージョンアップ時の後方互換性を自動処理
- **メモリ最適化**: 画像キャッシュ上限（100MB）でOOMを防止

---

## 対応言語 / Supported Languages

20言語に対応しています。

| 言語 | | 言語 | |
|-----|--|-----|--|
| 日本語 | 🇯🇵 | English | 🇺🇸 |
| 한국어 | 🇰🇷 | 中文(簡体) | 🇨🇳 |
| 中文(繁体) | 🇹🇼 | Español | 🇪🇸 |
| Français | 🇫🇷 | Deutsch | 🇩🇪 |
| Português (BR) | 🇧🇷 | Русский | 🇷🇺 |
| हिन्दी | 🇮🇳 | العربية | 🇸🇦 |
| Indonesia | 🇮🇩 | Melayu | 🇲🇾 |
| ภาษาไทย | 🇹🇭 | Tiếng Việt | 🇻🇳 |
| Italiano | 🇮🇹 | Nederlands | 🇳🇱 |
| Polski | 🇵🇱 | Türkçe | 🇹🇷 |

---

## セットアップ / Getting Started

### 必要環境 / Requirements

- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0 <4.0.0`

### インストール

```bash
# リポジトリをクローン
git clone https://github.com/<your-username>/oshikatu.git
cd oshikatu

# 依存関係をインストール
flutter pub get

# Hiveのコード生成
flutter pub run build_runner build --delete-conflicting-outputs

# アプリを起動
flutter run
```

---

## 工夫した点 / Technical Highlights

### オフラインファースト設計
Hive を採用することで、ネットワーク接続なしでもすべての機能を利用可能。ローカルDBのスキーマ変更に対応したデータマイグレーション機能も実装済み。

### 多言語対応（20言語）
Easy Localization を活用し、ARBファイルで20言語を管理。アラビア語のRTLレイアウトにも対応。

### 広告マネタイズ
Google Mobile Ads を使用したネイティブ広告・リワード広告を実装。アプリのライフサイクルに合わせた広告表示制御を行い、UXを損なわない広告体験を実現。

### 動的テーマ
推しごとにテーマカラーを設定でき、Provider で全体のUIにリアルタイム反映。

---

## ライセンス / License

This project is for portfolio purposes. All rights reserved.

---

<p align="center">Made with ❤️ for oshi-katsu fans around the world</p>
