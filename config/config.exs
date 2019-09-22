use Mix.Config

config :dm_web_front,
  namespace: EfaMonitor.DmFront.Web,
  generators: [context_app: false]

# Configures the endpoint
config :dm_web_front, EfaMonitor.DmFront.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "qNnmN42gFW7vVpkW3UqD7XiAbuiBdT1JUuNMWuwGundZFKhifWwXBz3tnfzdyg21",
  render_errors: [view: EfaMonitor.DmFront.Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: EfaMonitor.DmFront.Web.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "NZIguRPO"]

config :phoenix,
  template_engines: [leex: Phoenix.LiveView.Engine]

config :phoenix, :json_library, Jason

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

import_config "#{Mix.env()}.exs"
