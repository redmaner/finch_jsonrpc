defmodule Jsonrpc.Response do
  @moduledoc """
  `Jsonrpc.Response` represents a JSONRPC 2.0 response
  """

  alias Jsonrpc.Error

  @type t :: %__MODULE__{
          jsonrpc: String.t(),
          result: any() | nil,
          error: Error.t() | nil,
          id: String.t() | integer() | nil
        }

  @enforce_keys [:jsonrpc, :id]
  defstruct [:jsonrpc, :result, :error, :id]

  def new(data) when is_list(data), do: data |> extract_batch_response()

  def new(data), do: data |> extract_response_from_json()

  defp extract_batch_response(data) do
    data
    |> Stream.map(&extract_response_from_json/1)
    |> Enum.sort()
  end

  defp extract_response_from_json(%{"jsonrpc" => _version, "error" => error, "id" => id}) do
    %__MODULE__{
      jsonrpc: "2.0",
      error: error |> Error.new(),
      id: id
    }
  end

  defp extract_response_from_json(%{"jsonrpc" => _version, "result" => result, "id" => id}) do
    %__MODULE__{
      jsonrpc: "2.0",
      result: result,
      id: id
    }
  end
end
