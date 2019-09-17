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

# api configs for the transport authority in Germany
# dm: departure monitor
config :dm_core, :api, %{
  vrr: %{
    scheme: :http,
    host: "efa.vrr.de",
    apis: %{
      dm: "/standard/XSLT_DM_REQUEST"
    }
  },
  vvs: %{
    scheme: :http,
    host: "www2.vvs.de",
    apis: %{
      dm: "/vvs/XSLT_DM_REQUEST"
    }
  },
  mvv: %{
    scheme: :https,
    host: "efa.mvv-muenchen.de",
    apis: %{
      dm: "/mobile/XSLT_DM_REQUEST"
    }
  },
  nvbw: %{
    scheme: :http,
    host: "www.efa-bw.de",
    apis: %{
      dm: "/nvbw/XSLT_DM_REQUEST"
    }
  }
}

config :logger, :console, format: "[$level] $message\n"
config :logger, level: :info
