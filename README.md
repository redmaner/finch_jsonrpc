# FinchJsonrpc

`Jsonrpc` is a simple JSON-RPC HTTP client built on `Finch` It implements the JSON-RPC 2.0 [specification](https://www.jsonrpc.org/)

## Installation

The package can be installed
by adding `finch_jsonrpc` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:finch_jsonrpc, "~> 0.1.0"}
  ]
end
```

The docs can be found at [https://hexdocs.pm/finch_jsonrpc](https://hexdocs.pm/finch_jsonrpc).


## Starting under a supervisor
Jsonrpc is preferably started under a `Supervisor`. See `Jsonrpc.start_link/1` for more information:

```elixir
defmodule MyApp.Application do
  use Application

  def start(_type, _args) do
    children = [
      %{
        id: Jsonrpc,
        start: {Jsonrpc, :start_link, [name: :example]}
      }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

## Making a single request
Jsonrpc requests can be created using `Jsonrpc.Request.new/1` and send using `Jsonrpc.call/2`

```
Jsonrpc.Request.new(method: "exampleMethod")
|> Jsonrpc.call(name: :example, url: "https://finchjsonrpc.redmaner.com)
```

## Making a batch request
Jsonrpc supports batch requests. When the request is a list of requests, a batch RPC call is made automatically.
See `Jsonrpc.Request.new/2` on how to make batch requests.

```
Jsonrpc.Request.new(method: "exampleMethod")
|> Jsonrpc.Request.new(method: "exampleMethodTwo")
|> Jsonrpc.call(name: :example, url: "https://finchjsonrpc.redmaner.com)
```
