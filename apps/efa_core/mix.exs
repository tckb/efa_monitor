defmodule EfaMonitor.EfaCore.MixProject do
  use Mix.Project

  def project do
    [
      app: :efa_core,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {EfaMonitor.EfaCore.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:mojito, "~> 0.5.0", override: true},
      {:jason, "~> 1.1"},
      {:castore, "~> 0.1.0"},
      {:timex, "~> 3.6.1"}
    ]
  end
end
