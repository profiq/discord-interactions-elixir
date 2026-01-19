defmodule DiscordInteractions.MixProject do
  use Mix.Project

  def project do
    [
      app: :discord_interactions,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      source_url: "https://github.com/profiq/discord-interactions-elixir",
      test_coverage: [summary: [threshold: 80]]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    """
    An Elixir library for handling Discord interaction webhooks, which can be used to implement application commands
    with simple chat responses, as well as more complex user interfaces using components.
    """
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/profiq/discord-interactions-elixir"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug, "~> 1.17"},
      {:ed25519, "~> 1.4"},
      {:jason, "~> 1.2"},
      {:tesla, "~> 1.14"},
      {:mimic, "~> 2.3", only: :test},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end
end
