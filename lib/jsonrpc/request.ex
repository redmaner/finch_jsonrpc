defmodule Jsonrpc.Request do
  @moduledoc """
  `Jsonrpc.Request` represents a JSONRPC 2.0 request
  """

  @type t :: %__MODULE__{
          jsonrpc: String.t(),
          method: String.t(),
          params: any() | [any()],
          id: String.t() | integer() | nil
        }

  @enforce_keys [:jsonrpc, :method]
  defstruct [:jsonrpc, :method, :params, :id]
end
