defmodule Jsonrpc do
  def child_spec(opts) do
    name = opts |> Keyword.get(:name) || raise "You must supply a name"

    %{
      id: name,
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  def start_link(opts) do
    Finch.start_link(opts)
  end

  def request() do
  end
end
