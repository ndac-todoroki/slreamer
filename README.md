# Slreamer

Slack + Streamer = Slreamer

Slackのスレッドに召喚するとそれ以降のコメントをWebsocketで流すBotです。

「コメント太郎召喚」で召喚されます。
「コメント太郎粉砕」でキックされます。

## 構成

Plugアプリケーションです。
ベーシックなWebsocketを利用していて、接続クライアント一覧をGenServerで管理しています。
