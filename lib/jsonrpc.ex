defmodule Jsonrpc do
  require Logger
  alias Jsonrpc.{Error, Response}

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

  def raw(request, options \\ []) do
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
    |> wrap_response()
  rescue
    Jason.DecodeError ->
      {:error, "Could not decode response: no JSON: #{inspect(body)}"}
  end

  defp wrap_response(resp = %Response{error: %Error{}}), do: {:error, resp}

  defp wrap_response(resp), do: {:ok, resp}

  def request(request, options) do
    request
    |> raw(options)
    |> unwrap_result()
  end

  defp unwrap_result({:error, %Response{error: error}}), do: {:error, error}

  defp unwrap_result({:ok, %Response{result: result}}), do: {:ok, result}

  def request!(request, options) do
    request
    |> raw(options)
    |> unwrap_raise_error()
  end

  defp unwrap_raise_error({:error, %Response{error: error}}), do: raise error

  defp unwrap_raise_error({:ok, %Response{result: result}}), do: result
end
