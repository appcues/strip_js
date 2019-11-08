defmodule StripJs.Mixfile do
  use Mix.Project

  def project do
    [
      app: :strip_js,
      version: "0.9.2",
      description: "Strip JavaScript from HTML and CSS",
      package: package(),
      elixir: "~> 1.2",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: [
        docs: "docs --source-url https://github.com/appcues/strip_js"
      ]
    ]
  end

  def package do
    [
      licenses: ["MIT"],
      maintainers: ["pete gamache <pete@appcues.com>"],
      links: %{github: "https://github.com/appcues/strip_js"}
    ]
  end

  def application do
    [
      applications: [:logger]
    ]
  end

  defp deps do
    [
      {:floki, "~> 0.23.0"},
      {:html5ever, "~> 0.7.0"},
      {:ex_spec, "~> 2.0", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:dialyxir, ">= 0.0.0", only: :dev},
      {:freedom_formatter, "~> 1.1.0", only: :dev}
    ]
  end
end
