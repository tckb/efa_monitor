use Mix.Config

config :dm_phoenix_front,
  namespace: EfaMonitor.DmPhx

# Configures the endpoint
config :dm_phoenix_front, EfaMonitor.DmPhxWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Bxm0yoctqX3NoAYyrVo2ZXA28lnqkaLcIrv29HTx9kLzR+72LrO1FKj/A+d5uoys",
  render_errors: [view: EfaMonitor.DmPhxWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: EfaMonitor.DmPhx.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :dm_scenic_front, :viewport, %{
  name: :main_viewport,
  size: {700, 600},
  default_scene: {DmScenicFront.Scene.Splash, DmScenicFront.Scene.Sensor},
  drivers: [
    %{
      module: Scenic.Driver.Glfw,
      name: :glfw,
      opts: [resizeable: false, title: "dm_scenic_front"]
    }
  ]
}

import_config "#{Mix.env()}.exs"
