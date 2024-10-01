defmodule Crc24.MixProject do
  use Mix.Project

  def project do
    [
      app: :crc24,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  def application do
    [
      extra_applications:
        case Mix.env() do
          # elixir 1.15 added code pruning which removes observer unless we say to keep it
          :dev -> [:logger, :observer, :wx, :runtime_tools]
          _ -> [:logger]
        end
    ]
  end

  defp deps do
    [
      {:rustler, "~> 0.34", runtime: false},
      {:credo, "~> 1.7", runtime: false, only: [:dev, :test]},
      {:gradient, github: "esl/gradient", runtime: false, only: [:dev, :test]},
      {:dialyxir, "~> 1.4", runtime: false, only: [:dev, :test]},
      {:stream_data, "~> 1.1", runtime: false, only: [:dev, :test]},
      {:ex_doc, ">= 0.0.0", runtime: false, only: :dev}
    ]
  end

  defp aliases do
    [
      clippy: clippy(),
      cargo_test: cargo_test()
    ]
  end

  defp clippy do
    Enum.flat_map(Path.wildcard("native/*"), fn nif ->
      [
        fn _ -> Mix.shell().info("Linting #{Path.basename(nif)}...") end,
        "cmd --cd #{nif} cargo clippy --color always"
      ]
    end)
  end

  defp cargo_test do
    Enum.flat_map(Path.wildcard("native/*"), fn nif ->
      [
        fn _ -> Mix.shell().info("Testing #{Path.basename(nif)}...") end,
        "cmd --cd #{nif} cargo test --color always"
      ]
    end)
  end
end
