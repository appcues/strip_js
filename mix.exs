defmodule StripJs.Mixfile do
  use Mix.Project

  def project do
    [app: :strip_js,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:floki, "~> 0.17.2"},
      {:ex_spec, "~> 2.0", only: :test},
    ]
  end
end
