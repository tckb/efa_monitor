defmodule EfaMonitor.DmCore.MixProject do
  @moduledoc false
  use Mix.Project

  def project do
    [
      app: :dm_core,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {EfaMonitor.DmCore.Application, []}
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
