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

  def request(request, options \\ []) do
    with {name, options} <- options |> Keyword.pop!(:name),
         {url, options} <- options |> Keyword.pop!(:url),
         {headers, options} <- options |> Keyword.pop(:headers, []),
         true <- is_list(headers) and is_binary(url),
         uri <- URI.parse(url),
         {:ok, body} <- Jason.encode(request) do
      %Finch.Request{
        host: uri.host,
        path: uri.path,
        query: uri.query,
        port: uri.port,
        scheme: uri.scheme,
        body: body,
        headers: headers,
        method: :post
      }
      |> Finch.request(name, options)
    else
      _ -> raise "sike"
    end
  end
end
