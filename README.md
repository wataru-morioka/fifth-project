## iOS アプリ
### 概要
複数のアプリ登録者（ランダム）に2択アンケートを投げかけ、制限時間が過ぎるとプッシュ通知を受信、回答結果を確認できる  
自身が回答者として選出され、回答者になることもある
### バックグラウンド
- firebase authentication（google認証）  
- firebase firestore  
- firebase functions・・・別途「sixth-project」リポジトリ
### 画面一覧
- google認証サインイン画面
- アカウント登録画面
- メイン画面（タブ4つ）
  - 自身の質問一覧
  - 回答者として受信した質問一覧
  - 新規質問投稿
  - アカウント情報変更
- 質問詳細画面
  - 自身の質問詳細画面
  - 回答者として受信した質問詳細画面
### 機能一覧
- firebase google認証機能  
- 自動ログイン機能  
- アカウント登録、更新機能  
- 質問投稿、受信、詳細確認機能  
- 回答結果受信機能  
- firestore更新監視機能  
- サーバ側DBとネイティブDBの同期  
- ネイティブDB（Realm Database）  
- ORマッパー  
- MVVM方式採用  
- Reactive Extentions機能（RxSwift・RxRealm）  
- ネイティブDBと画面の同期機能（RxRealm）  
- ネットワーク状態監視機能  
- firebaseプッシュ通知機能  
- 画面入力値バリデーション機能  
- google analytics機能  

