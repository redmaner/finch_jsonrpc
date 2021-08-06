defmodule Jsonrpc.Error do
  @moduledoc """
  `Jsonrpc.Error` represents a JSONRPC 2.0 error
  """

  @type t :: %__MODULE__{
          code: integer(),
          message: String.t(),
          data: any() | nil
        }

  @enforce_keys [:code]
  defstruct [:code, :message, :data]
end
