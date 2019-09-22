use Mix.Config

config :dm_web_front, EfaMonitor.DmFront.Web.Endpoint,
  http: [port: 4000],
  # https: [port: 4001, certfile: "priv/cert/selfsigned.pem", keyfile: "priv/cert/selfsigned_key.pem"],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  protocol_options: [
    max_header_name_length: 64,
    max_header_value_length: 140_096,
    max_headers: 100
  ],
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
      "--display",
      "minimal",
      cd: Path.expand("../apps/dm_web_front/assets", __DIR__)
    ]
  ]

config :dm_web_front, EfaMonitor.DmFront.Web.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/dm_web_front/{live,views}/.*(ex)$",
      ~r"lib/dm_web_front/templates/.*(eex)$"
    ]
  ]

config :logger, :console, format: "[$level] $message\n"
config :logger, level: :info
