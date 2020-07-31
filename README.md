# Slreamer

Slack + Streamer = Slreamer

Slackのスレッドに召喚するとそれ以降のコメントをWebsocketで流すBotです。

`/invite` でBotを招待すると次のコマンドに反応するようになります。
「いでよコメント太郎」でモニタリングを開始します。
「鎮まれコメント太郎」でモニタリングをやめます。
「去れコメント太郎」でキックされます。

## 構成

Plugアプリケーションです。
ベーシックなWebsocketを利用していて、接続クライアント一覧をGenServerで管理しています。

## Dev起動

```zsh
$ git clone <git url>
$ cd slreamer
$ mix deps.get
$ env SLREAMER_SLACK_TOKEN=xxxxxxxxxxxx iex -S mix  # Slackへの書き込みにはSlackのBot OAuth Tokenが必要です
```

`asdf-vm` などで Elixir 1.10.0 以上を利用できるようにしておいてください。
`localhost:4000` にサーバーが起動するので、 `ws://localhost:4000/ws` に繋ぎにいくことができます。
SlackのWebhooksには `/webhooks` エンドポイントを設定してください。（ngrokなどでドメインを用意する必要があります）
