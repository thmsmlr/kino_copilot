defmodule KinoCopilot.MixProject do
  use Mix.Project

  def project do
    [
      app: :kino_copilot,
      version: "0.1.2",
      description: "Bringing ChatGPT to you livebook",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {KinoCopilot.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:kino, "~> 0.7"},
      {:openai, "~> 0.5.4"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
  
  def package do
    [
      maintainers: ["Thomas Millar"],
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => "https://github.com/thmsmlr/kino_copilot"
      }
    ]
  end
end
