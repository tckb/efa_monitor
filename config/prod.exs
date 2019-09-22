use Mix.Config

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

port =
  System.get_env("PORT") ||
    raise """
    environment variable PORT is missing.
    """

config :dm_web_front, EfaMonitor.DmFront.Web.Endpoint,
  http: [:inet6, port: String.to_integer(port)],
  secret_key_base: secret_key_base,
  cache_static_manifest: "priv/static/cache_manifest.json"

config :logger, :console, format: "[$level] $message\n"
config :logger, level: :info
