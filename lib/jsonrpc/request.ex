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

  def new(opts) when is_list(opts) do
    method =
      opts
      |> Keyword.get(:method, :not_given)
      |> case do
        :not_given -> raise "Method is not given"
        method when is_binary(method) -> method
        _ -> raise "Method is invalid, should be a string"
      end

    %__MODULE__{
      jsonrpc: "2.0",
      method: method
    }
    |> add_params(opts |> Keyword.get(:params, :not_given))
    |> add_id(opts |> Keyword.get(:id, :not_given))
  end

  defp add_params(req, :not_given), do: req

  defp add_params(req, params) do
    req
    |> Map.put(:params, params)
  end

  defp add_id(req, :not_given), do: req

  defp add_id(req, id) when is_binary(id) or is_integer(id) or is_nil(id) do
    req
    |> Map.put(:id, id)
  end

  defp add_id(_req, _id), do: raise("ID is invalid: should be a string an integer or nil")

  def new(req = %__MODULE__{}, opts) when is_list(opts) do
    [req] ++ [new(opts)]
  end

  def new(req_list, opts) when is_list(opts) do
    req_list ++ [new(opts)]
  end

  def add_ids(req_list, starting_number \\ 1) when is_list(req_list) do
    req_list
    |> Enum.reduce({starting_number, []}, fn req, {req_id, requests} ->
      req =
        req
        |> Map.put(:id, req_id)

      {req_id + 1, requests ++ [req]}
    end)
    |> unwrap_requests()
  end

  defp unwrap_requests({_req_id, requests}), do: requests
end
