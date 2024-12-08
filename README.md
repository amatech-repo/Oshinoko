# Oshinoko
以下は、プロジェクトの `README.md` に記載するブランチルールとコミットルールのテンプレートです。これを参考にしてください！

## MIRATABI
- 将来、行きたい旅行先をリスト化して管理するアプリ。テレビやSNSで気になる・行ってみたいと思ったお店や観光地をリスト化することで次の旅行への楽しみを増やしつつ、行き先を選びやすくしてくれます。地図上から行きたい場所をピンで指すことでリストに保存すると共に、近くにある他の行きたい場所が地図上で直感的にわかりやすく、旅行計画が建てやすくなります。他のユーザーと共有する機能やAIとの会話による提案機能でこれからの旅行をより楽しませてくれるでしょう。

## 背景・課題
- あまてくソンというハッカソンに参加し、与えられたテーマ"継続開発がしたくなるプロダクトを作ろう"を基に私たちの好きなことでプロダクトを作れば継続的に開発できるんじゃね？と考えました。それこそが旅行でした。私たちは旅行が好きだけど、次の旅行先に迷ったり、行きたかった旅行先を思い出せないことなどがありました。それを解決するために考えたのが"MIRATABI"。気になる/行きたい場所をリスト化することで次の旅行への楽しみが増えつつ、行き先を選びやすくなるようなアプリを作ろうと考えました。行き先とその周辺の行きたい場所がわかるとそれらの混雑度合いなどを想定した上で旅行計画を練れるのでオーバーツーリズムの課題にもアプローチできるのではないかと考えました。

### デモ画像
<img src = "https://github.com/user-attachments/assets/38b3be2d-3d64-4d9c-bd2c-206b8601e218" width = "200">
<img src = "https://github.com/user-attachments/assets/e92961fe-4409-49d8-8460-088cabc85d90" width = "200">
<img src = "https://github.com/user-attachments/assets/79589473-fb7f-42b9-9bd9-79c2830c63f5" width = "200">
<img src = "https://github.com/user-attachments/assets/522bd275-3957-4a14-8494-278488fc289d" width = "200">
<img src = "https://github.com/user-attachments/assets/71e1fbd1-16f4-4cef-9c8b-2a7056a7d704" width = "200">
<img src = "https://github.com/user-attachments/assets/4d5a6f95-edf2-486c-a7eb-14789fb8fdfe" width = "200">
<img src = "https://github.com/user-attachments/assets/2f962df0-dd71-4034-9245-bfe53b4353a4" width = "200">
<img src = "https://github.com/user-attachments/assets/6dcca820-9682-436a-8023-dfebea095bb4" width = "200">



## リンク
- [Oshinoko リポジトリ](https://github.com/orukahairuka/Oshinoko)

## 環境
- **Xcode**: 15.4
- **Swift**: 5.10

## プラットフォーム
- **iOS**: 17.5

## 使用技術
- Swift
- Lottie
- Google Places 
- Gemini
- Alamofire
- Firestore
- Github

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

## 注力したポイント
-シンプルなUI
-直感的な操作方法
-多彩なアニメーション

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

