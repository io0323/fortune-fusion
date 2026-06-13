---
name: Fortune Fusion スキャフォールド
description: Flutter統合占術アプリの構成・設計方針・現在の実装状況
type: project
---

スキャフォールド生成完了（flutter analyze: No issues found）。

**Why:** 四柱推命・西洋占星術・九星気学の三占術統合アプリ。完全オフライン。

**How to apply:** 次タスクは占術エンジン実装（ShichuEngine → SeizaEngine → KyuseiEngine の順が推奨）。

## 技術スタック
- Flutter / Dart SDK >=3.3.0
- Riverpod 2.x + riverpod_annotation (@riverpod アノテーション)
- go_router 14.x
- drift 2.x (SQLite ORM)
- Clean Architecture (Presentation/Domain/Data)

## 実装済み（スタブ）
- lib/features/meishiki/domain/engines/ — ShichuEngine, SeizaEngine, KyuseiEngine (UnimplementedError)
- lib/shared/database/app_database.dart — Profiles / FortuneCache テーブル定義
- lib/app.dart — go_router 8ルート定義
- assets/tables/*.json — 暦テーブル（十干・十二支・九星・西洋星座）

## 未実装（次に着手すべき）
1. ShichuEngine.calculate() — 万年暦アルゴリズム
2. SeizaEngine.calculate() — Swiss Ephemerisベース
3. KyuseiEngine.calculate() — 本命星・吉方位算出
4. ProfileLocalDatasourceImpl — driftを使ったDB操作
5. FortuneRepositoryImpl — 運勢生成ロジック
