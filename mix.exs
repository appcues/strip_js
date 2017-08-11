defmodule StripJs.Mixfile do
  use Mix.Project

  def project do
    [
      app: :strip_js,
      version: "0.6.0",
      description: "Strip JS from HTML strings or parse trees",
      package: package(),
      elixir: "~> 1.2",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
   ]
  end

  def package do
    [
      licenses: ["MIT"],
      maintainers: ["pete gamache <pete@appcues.com>"],
      links: %{github: "https://github.com/appcues/strip_js"},
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:floki, "~> 0.17.2"},
      {:ex_spec, "~> 2.0", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:dialyxir, ">= 0.0.0", only: :dev},
    ]
  end
end

