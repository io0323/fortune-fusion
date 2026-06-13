# アーキテクチャルール

## レイヤー依存関係
Presentation → Domain ← Data
ApplicationはDomainのUseCaseを呼び出す。
DataはDomainのRepositoryインターフェースを実装する。

## 新規feature追加時の手順
1. domain/entities/ にEntityを定義
2. domain/repositories/ にインターフェースを定義
3. domain/usecases/ にUseCaseを実装
4. data/repositories/ にImpl を実装
5. presentation/providers/ にRiverpod Providerを定義
6. presentation/pages/ にPageを実装
