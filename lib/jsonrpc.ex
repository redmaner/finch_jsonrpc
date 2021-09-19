defmodule Jsonrpc do
  @moduledoc """
  `Jsonrpc` is a simple JSON-RPC HTTP client built on `Finch` It implements the JSON-RPC 2.0 [specification](https://www.jsonrpc.org/)

  # Starting under a supervisor
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
  """

  require Logger

  import Injector
  inject Finch, as: FinchHTTP

  alias Jsonrpc.{Error, Response}
  alias Jsonrpc.Error.ResponseException

  @doc false
  def child_spec(opts) do
    name = opts |> Keyword.get(:name) || raise "You must supply a name"

    %{
      id: name,
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  @doc """
  `start_link/1` is used to start Jsonrpc under a supervisor. A required option is `name`, which is used to
  communicate with `Finch`. For more options see `Finch.start_link/1`.

  ## Example:
  ```
  iex(1)> Jsonrpc.start_link(name: :example)
  {:ok, #PID<0.232.0>}
  ```
  """
  @spec start_link(opts :: list) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(opts) do
    Finch.start_link(opts)
  end

  @spec call_raw(request :: Request.t(), options :: list()) ::
          {:ok, responses :: [Response.t()]}
          | {:ok, response :: Response.t()}
          | {:error, responses :: [Response.t()]}
          | {:error, response :: Response.t()}
          | {:error, reason :: term()}
  def call_raw(request, options \\ []) do
    with {name, options} <- options |> Keyword.pop!(:name),
         {url, options} <- options |> Keyword.pop!(:url),
         {headers, options} <-
           options |> Keyword.pop(:headers, [{"content-type", "application/json"}]),
         {:ok, body} <- Jason.encode_to_iodata(request),
         true <- is_list(headers) and is_binary(url) do
      :post
      |> Finch.build(url, headers, body)
      |> FinchHTTP.request(name, options)
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

  defp handle_response({:ok, resp = %Finch.Response{}}) do
    {:error,
     %Response{
       jsonrpc: "2.0",
       error: %Error{
         code: -32010,
         type: :server_error,
         message: "Server error",
         data: resp
       }
     }}
  end

  defp wrap_response(resp = %Response{error: %Error{}}), do: {:error, resp}

  defp wrap_response(resp) when is_list(resp), do: resp |> wrap_batch_response()

  defp wrap_response(resp), do: {:ok, resp}

  defp wrap_batch_response(responses) do
    wrap_type =
      responses
      |> Enum.reduce_while(:ok, fn resp, _acc ->
        case resp do
          %Response{error: %Error{}} ->
            {:halt, :error}

          %Response{} ->
            {:cont, :ok}
        end
      end)

    {wrap_type, responses}
  end

  def call(request, options \\ []) do
    request
    |> call_raw(options)
    |> unwrap_result()
  end

  defp unwrap_result({:error, %Response{error: error}}), do: {:error, error}

  defp unwrap_result({:error, reason}), do: {:error, reason}

  defp unwrap_result({:ok, %Response{result: result}}), do: {:ok, result}

  defp unwrap_result(result), do: result

  def call!(request, options \\ []) do
    request
    |> call_raw(options)
    |> unwrap_raise_error()
  end

  # Raise error when error is a list of responses
  defp unwrap_raise_error({:error, reason}) when is_list(reason),
    do: raise(ResponseException.new(reason))

  # Raise error when error is JSONRPC error
  defp unwrap_raise_error({:error, %Response{error: error}}),
    do: raise(ResponseException.new(error))

  # Raise everything else (json decode error / finch error)
  defp unwrap_raise_error({:error, reason}), do: raise "#{inspect(reason)}"

  defp unwrap_raise_error({:ok, result}) when is_list(result), do: result

  defp unwrap_raise_error({:ok, %Response{result: result}}), do: result
end
