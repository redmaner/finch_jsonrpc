defmodule Jsonrpc.Error do
  @moduledoc """
  `Jsonrpc.Error` represents a JSONRPC 2.0 error
  """

  @type t :: %__MODULE__{
          code: integer(),
          type: error_type(),
          message: String.t(),
          data: any() | nil
        }

  @type error_type ::
          :parse_error
          | :invalid_request
          | :method_not_found
          | :invalid_params
          | :internal_error
          | :server_error
          | :unknown

  @enforce_keys [:code]
  defstruct [:code, :type, :message, :data]

  def new(error_data = %{"code" => code}) do
    %__MODULE__{
      code: code,
      type: code |> extract_type(),
      message: error_data |> Map.get("message", ""),
      data: error_data |> Map.get("data", nil)
    }
  end

  defp extract_type(-32700), do: :parse_error

  defp extract_type(-32600), do: :invalid_request

  defp extract_type(-32601), do: :method_not_found

  defp extract_type(-32602), do: :invalid_params

  defp extract_type(-32603), do: :internal_error

  defp extract_type(code) when code > -32099 and code < -32000, do: :server_error

  defp extract_type(_code), do: :unknown
end
