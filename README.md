# アプリケーション名
Adventure

# アプリケーション概要
一緒に冒険する仲間を探すアプリケーション

# 利用方法
  ↓email,passwordを設定しユーザー登録

  [![Image from Gyazo](https://i.gyazo.com/563e681772ff4937dadac365d045bcac.png)](https://gyazo.com/563e681772ff4937dadac365d045bcac)
  

  ↓名前を決める

  [![Image from Gyazo](https://i.gyazo.com/6eae078b8ecf64c7cd444542ac60e3e5.png)](https://gyazo.com/6eae078b8ecf64c7cd444542ac60e3e5)
  
  
  ↓行き先の選択（ジャンル）

  [![Image from Gyazo](https://i.gyazo.com/e8d68714c63b4462e5a8427ca2df8894.jpg)](https://gyazo.com/e8d68714c63b4462e5a8427ca2df8894)
  
  ↓ジャンルに類する部屋の一覧から選択

  [![Image from Gyazo](https://i.gyazo.com/ce0e8cfeab46ad66fd089f228a96a08c.png)](https://gyazo.com/ce0e8cfeab46ad66fd089f228a96a08c)
  
  ↓詳細が表示され内容がよければ参加を押す

  [![Image from Gyazo](https://i.gyazo.com/d64412917dfae95ccf38c27d732443a9.png)](https://gyazo.com/d64412917dfae95ccf38c27d732443a9)
  
  ↓その部屋のチャットルームが開くのでコミュニケーションを取り決行する。

  [![Image from Gyazo](https://i.gyazo.com/662f69d8e59617ff438e15bb828fd400.png)](https://gyazo.com/662f69d8e59617ff438e15bb828fd400)


  - 部屋一覧で部屋作成することもできる。
  - 部屋の詳細画面は参加したメンバーで決まった内容などを書き込めるように編集できる。

  # 目指した課題解決
- ワクワクを共有できる仲間が周りに居ない
- 一人で挑戦するのは不安

# 工夫した点
- Firebaseを使ったサーバーサイドの実装
- リアルタイムでのチャット

# 洗い出した要件
- https://docs.google.com/spreadsheets/d/1ptD_lHr12gVQJV_pjUgENGp4ooPhLYcCM2RrN6xcjZE/edit?usp=sharing

# 使用技術
- Flutter version 2.0.6
- Firebase
  - Cloud Firestore: ^1.0.7
  - Authentication: ^1.1.2

# 機能一覧
- ユーザー登録/ログイン機能
- トークルーム作成
- トークルーム詳細編集機能
- チャット機能

# 実装予定の機能
- スケジュール管理機能
- ToDoリスト機能
- マイページ機能