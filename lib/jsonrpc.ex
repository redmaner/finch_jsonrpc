defmodule Jsonrpc do
  require Logger
  alias Jsonrpc.Response

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
         {headers, options} <-
           options |> Keyword.pop(:headers, [{"content-type", "application/json"}]),
         {:ok, body} <- Jason.encode_to_iodata(request),
         true <- is_list(headers) and is_binary(url) do
      :post
      |> Finch.build(url, headers, body)
      |> Finch.request(name, options)
      |> handle_response()
    else
      error ->
        error
    end
  end

  defp handle_response(error = {:error, _reason}), do: error

  defp handle_response({:ok, %Finch.Response{status: 200, body: body}}) do
    body
    |> Jason.decode!()
    |> Response.new()
  rescue
    Jason.DecodeError ->
      {:error, "Could not decode response: no JSON: #{inspect(body)}"}
  end
end
