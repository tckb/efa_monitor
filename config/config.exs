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

import_config "#{Mix.env()}.exs"
