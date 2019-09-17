use Mix.Config

config :dm_web_front, EfaMonitor.DmFront.Web.Endpoint,
  url: [host: "example.com", port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json"
