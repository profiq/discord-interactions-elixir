defmodule DiscordInteractions.MixProject do
  use Mix.Project

  def project do
    [
      app: :discord_interactions,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
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
      {:mimic, "~> 1.7", only: :test}
    ]
  end
end
