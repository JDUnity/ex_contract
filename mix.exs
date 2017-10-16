defmodule ExContract.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ex_contract,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
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
      elixirc_paths: elixirc_paths(Mix.env),
      test_pattern: "*_test.exs",
      warn_test_pattern: "test.ex"
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
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:distillery, "~> 0.10", runtime: false},
      {:credo, "~> 0.7", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false}
    ]
  end
end
