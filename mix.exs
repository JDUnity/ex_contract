defmodule ExContract.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ex_contract,
      version: "0.1.2",
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      # Docs
      name: "Ex Contract",
      source_url: "https://github.com/JDUnity/ex_contract",
      homepage_url: "http://unitypos.com",
      docs: [
        main: "readme",
        logo: "JD_Unity2_128x128.png",
        extras: ["README.md"]
      ],
      # Testing setup to enable dialyzer. Tests are implemented in .ex files to allow dialyzer to
      # perform type checking. They are run using .exs files.
      elixirc_paths: elixirc_paths(Mix.env()),
      test_pattern: "*_test.exs",
      warn_test_pattern: "test.ex"
    ]
  end

  defp description() do
    "This is Elixir library application that adds support for design by contract. For intro to DbC
    methodology see https://en.wikipedia.org/wiki/Design_by_contract."
  end

  defp package() do
    [
      maintainers: ["Dariusz Gawdzik", "John Inglis"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/JDUnity/ex_contract"}
    ]
  end

  # Specifies which paths to compile per environment. We add additional path for test folder to
  # compile unit tests into beam files so we can run dialyzer on them.
  defp elixirc_paths(:prod), do: ["lib"]
  defp elixirc_paths(_), do: ["lib", "test"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 0.5", only: :dev, runtime: false},
      {:credo, "~> 0.8", only: :dev, runtime: false},
      {:ex_doc, "~> 0.18", only: :dev, runtime: false}
    ]
  end

end
