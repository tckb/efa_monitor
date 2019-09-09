use Mix.Config

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
  },
  rta_chicago: %{
    scheme: :http,
    host: "tripplanner.rtachicago.com",
    apis: %{
      dm: "/ccg3/XSLT_DM_REQUEST"
    }
  }
}

config :dm_phoenix_front, EfaMonitor.DmPhxWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: []

config :dm_phoenix_front, EfaMonitor.DmPhxWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/dm_phoenix_front_web/{live,views}/.*(ex)$",
      ~r"lib/dm_phoenix_front_web/templates/.*(eex)$"
    ]
  ]

config :logger, :console, format: "[$level] $message\n"
config :phoenix, :stacktrace_depth, 20
config :phoenix, :plug_init_mode, :runtime
config :logger, level: :info
