defmodule PixelConversionServer.MixProject do
  use Mix.Project

  def project do
    [
      app: :pixelconversionserver,
      version: "1.0.1",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript()
    ]
  end

  def application do
    applications = [:logger, :plug_cowboy, :poison, :httpoison, :quantum, :cachex, :decimal, :rollbax]
    mod = {PixelConversionServer, []}
    case :init.get_plain_arguments |> Enum.any?(&(&1=='escript.build')) do
      true ->
        [applications: applications]
      _ ->
        [applications: applications, mod: mod]
    end
  end

  def escript do
    [
      main_module: PixelConversionServer
    ]
  end

  defp deps do
    [
      {:plug_cowboy, "~> 2.0"},
      {:poison, "~> 3.1"},
      {:httpoison, "~> 1.7"},
      {:quantum, "~> 3.0"},
      {:cachex, "~> 3.3"},
      {:decimal, "~> 2.0"},
      {:rollbax, "~> 0.11.0"}
    ]
  end
end
