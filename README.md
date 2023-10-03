# Kino Copilot

[![Floki version](https://img.shields.io/hexpm/v/kino_copilot.svg)](https://hex.pm/packages/kino_copilot)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/kino_copilot/)

Bringing the power of ChatGPT into [Livebook](https://livebook.dev)!
KinoCopilot is a series of Kino SmartCells which allow you to have an AI Copilot help you write code.

![demo](https://github.com/thmsmlr/kino_copilot/assets/167206/4d38b1a3-4ca5-4898-a762-8170c6072aa9)

## Installation

To bring KinoCopilot to Livebook all you need to do is Mix.install/2:

```elixir
Mix.install([
  {:kino_copilot, "~> 0.1.1"}
])
```

By default we'll use the `LB_OPENAI_API_KEY` for the API key. 
Optionally, however, you can explicitly pass in your API key and specify which model to use. 

```elixir
Mix.install(
  [
    {:kino_copilot, "~> 0.1.0"}
  ], 
  config: [
    kino_copilot: [
      api_key: System.fetch_env!("LB_OPENAI_API_KEY"),
      model: "gpt-3.5-turbo"
    ]
  ]
)
```

## Development

KinoCopilot is still an active development.
If you want to contribute, here are some instructions that will help get you up and running.

First, you're going to want to install the package from source.

```elixir
Mix.install([
    {:kino_copilot, path: "/Users/thomas/code/kino_copilot"},
])
```

Then, if you're modifying any of the front-end bits, you'll want to make sure you have tailwind running in the background, recompiling the CSS. 

```bash
 $ npx tailwindcss -o lib/assets/code_writer_cell/main.css --content lib/assets/code_writer_cell/main.js --watch 
```

In the future when we have specialized code writer cells for various languages you'll want to run this command for the specific smart cell you are working on. 
