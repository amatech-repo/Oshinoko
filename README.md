# Oshinoko
以下は、プロジェクトの `README.md` に記載するブランチルールとコミットルールのテンプレートです。これを参考にしてください！

## MIRATABI
- 将来、行きたい旅行先をリスト化して管理するアプリ。テレビやSNSで気になる・行ってみたいと思ったお店や観光地をリスト化することで次の旅行への楽しみを増やしつつ、行き先を選びやすくしてくれます。地図上から行きたい場所をピンで指すことでリストに保存すると共に、近くにある他の行きたい場所が地図上で直感的にわかりやすく、旅行計画が建てやすくなります。他のユーザーと共有する機能やAIとの会話による提案機能でこれからの旅行をより楽しませてくれるでしょう。

## リンク
- [Oshinoko リポジトリ](https://github.com/orukahairuka/Oshinoko)

## 環境
- **Xcode**: 15.4
- **Swift**: 5.10

## プラットフォーム
- **iOS**: 17.5

## 実行手順
1. リポジトリをクローンします:
   ```bash
   git clone https://github.com/orukahairuka/PrefeFortune.git
   ```
2. `PrefeFortune.xcodeproj`をXcodeで開きます。

3. 以下の手順でライブラリを追加します:
   - **File > Add Package Dependencies** を選択。
   - 以下のパッケージをそれぞれ追加してください:
     - [Alamofire](https://github.com/Alamofire/Alamofire.git), バージョン `5.9.1`
     - [Lottie](https://github.com/airbnb/lottie-ios), バージョン `4.5.0`
     - [SwiftCSV](https://github.com/naoty/SwiftCSV.git), バージョン `0.10.0`

4. **Target > Signing & Capabilities** に移動し、**Team**を自分のApple開発者アカウントに設定します。  
   これによりコード署名の問題を回避し、iOSデバイス上での実行が可能になります。

5. 実行するデバイスを選択します。

6. プロジェクトをビルド・実行します。

## ブランチ運用ルール
### ブランチ構成
リポジトリのブランチは以下のように構成します：

- **`main`**:
  - 本番環境で稼働する安定版コードを管理するブランチ。
  - **直接コミットは禁止**。必ずプルリクエスト経由で変更を行います。

- **`develop`**:
  - 次回リリースに向けた開発中のコードを統合するブランチ。
  - 各機能ブランチ（`feature/*`）からの変更を統合します。

- **`feature/{機能名}`**:
  - 新機能や改修を開発するための一時的なブランチ。
  - 命名例: `feature/user-authentication`, `feature/add-api`

### マージポリシー
- `main` および `develop` ブランチへの直接コミットは禁止。
- **プルリクエスト（Pull Request）を必須**とし、最低1名のレビューアによる承認を得てからマージを行います。

---

## コミットルール

### コミットメッセージフォーマット

- **type**: 変更の種類
  - `feat`: 新機能の追加
  - `fix`: バグ修正
  - `docs`: ドキュメントの変更
  - `style`: フォーマットの変更（機能に影響しない）
  - `refactor`: リファクタリング

