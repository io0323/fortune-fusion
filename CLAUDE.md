# Fortune Fusion — CLAUDE.md

## プロジェクト概要
統合占術アプリ。四柱推命・西洋占星術・九星気学の三占術を組み合わせ、
性格・適職・恋愛・金運・健康・今日/今月/今年の運勢を表示する。
完全オフライン動作。サーバーレス。Flutter製。

## アーキテクチャ
Clean Architecture を厳守する。
- Presentation → Application → Domain → Data の依存方向のみ許可
- Domain層はFlutter/外部パッケージに依存しない純粋なDartコード
- 各featureは独立させ、feature間の直接参照を禁止する

## 占術エンジンの実装方針
- `lib/features/meishiki/domain/engines/` 配下に各エンジンを実装する
- エンジンはすべてPure Dartクラス（Flutterフレームワーク依存なし）
- 暦テーブルは `assets/tables/*.json` から読み込む
- 計算結果はイミュータブルなEntityクラスで返す
- エンジン単体でユニットテストを書く（`test/features/meishiki/`）

### 四柱推命（ShichuEngine）
- 万年暦アルゴリズムで年柱・月柱・日柱・時柱を算出
- 十干・十二支・通変星・十二運をすべて導出すること

### 西洋占星術（SeizaEngine）
- 太陽星座・月星座・ASC・MC・10惑星のハウスを算出
- 出生地の緯度経度・恒星時・黄道傾斜を使用する
- Swiss Ephemerisのアルゴリズムを参考にDartで実装する

### 九星気学（KyuseiEngine）
- 本命星・月命星・傾斜宮を算出
- 年盤・月盤を元に吉方位・凶方位を導出する

## コーディング規約
- Dart公式スタイルガイドに従う
- クラス名: UpperCamelCase
- ファイル名: snake_case
- Providerは riverpod_annotation の @riverpod アノテーションを使用
- 非同期処理はすべて AsyncValue で扱う
- マジックナンバーは定数化する（`core/constants/app_constants.dart`）

## 禁止事項
- Domain層でFlutterのimportを使わない
- feature間で直接importしない（共通処理は shared/ へ）
- ハードコードされた文字列をUI層に直書きしない

## よく使うコマンド
```bash
# コード生成（Riverpod + Drift）
flutter pub run build_runner build --delete-conflicting-outputs

# テスト実行
flutter test

# 静的解析
flutter analyze
```
