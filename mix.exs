defmodule EfaMonitor.MixProject do
  @moduledoc false

  use Mix.Project

  def project do
    [
      apps_path: "apps",
      version: "0.1.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_options: [warnings_as_errors: true],
      aliases: aliases(),
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
        ignore_warnings: ".dialyzer_ignore.exs"
      ],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      releases: [
        web_frontend: [
          include_executables_for: [:unix],
          applications: [dm_web_front: :permanent]
        ]
      ]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0.0-rc.6", only: [:dev, :test]},
      {:credo, "~> 1.1"},
      {:excoveralls, "~> 0.10", only: :test}
    ]
  end

  defp aliases do
    [
      quality: ["format", "dialyzer", "credo --strict"],
      test: ["test", "coveralls"]
    ]
  end
end
