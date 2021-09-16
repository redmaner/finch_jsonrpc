defmodule Jsonrpc.Response do
  @moduledoc """
  `Jsonrpc.Response` represents a JSONRPC 2.0 response, as documented in the
  [JSON-RPC 2.0 specification](https://www.jsonrpc.org/specification#response_object)
  """

  alias Jsonrpc.Error

  @type t :: %__MODULE__{
          jsonrpc: String.t(),
          result: any() | nil,
          error: Error.t() | nil,
          id: String.t() | integer() | nil
        }

  @enforce_keys [:jsonrpc]
  defstruct [:jsonrpc, :result, :error, :id]

  @doc false
  def new(data) when is_list(data), do: data |> extract_batch_response()

  def new(data), do: data |> extract_response_from_json()

  defp extract_batch_response(data) do
    data
    |> Stream.map(&extract_response_from_json/1)
    |> Enum.sort(&sort_requests_on_id/2)
  end

  defp extract_response_from_json(resp = %{"jsonrpc" => _version, "error" => error}) do
    %__MODULE__{
      jsonrpc: "2.0",
      error: error |> Error.new(),
      id: resp["id"]
    }
  end

  defp extract_response_from_json(resp = %{"jsonrpc" => _version, "result" => result}) do
    %__MODULE__{
      jsonrpc: "2.0",
      result: result,
      id: resp["id"]
    }
  end

  defp sort_requests_on_id(%__MODULE__{id: id_one}, %__MODULE__{id: id_two})
       when is_integer(id_one) and is_integer(id_two),
       do: id_one < id_two

  defp sort_requests_on_id(%__MODULE__{id: id_one}, %__MODULE__{id: id_two})
       when is_binary(id_one) and is_binary(id_two) do
    id_one |> String.to_integer() < id_two |> String.to_integer()
  rescue
    ArgumentError ->
      false
  end

  defp sort_requests_on_id(_one, _two), do: false
end
