defmodule Jsonrpc.Response do
  @moduledoc """
  `Jsonrpc.Response` represents a JSONRPC 2.0 response
  """

  @type t :: %__MODULE__{
          jsonrpc: String.t(),
          result: any() | nil,
          error: Jsonrpc.Error.t() | nil,
          id: String.t() | integer() | nil
        }

  @enforce_keys [:jsonrpc, :id]
  defstruct [:jsonrpc, :result, :error, :id]
end
