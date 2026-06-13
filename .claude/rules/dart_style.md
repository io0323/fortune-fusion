# Dartコーディングスタイル

- `final` を優先。`var` は型推論が自明な場合のみ
- Entityはfreezedまたは手書きのcopyWith/==を実装すること
- Providerのファミリーは引数をrecordで渡す
- エラーはResultパターン（Either相当）ではなくExceptionをthrowし、
  Riverpod の AsyncValue.error でキャッチする
