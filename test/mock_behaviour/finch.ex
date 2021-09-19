defmodule MockBehaviourFinch do
  @callback request(req :: Finch.Request.t(), name :: atom(), opts :: list()) :: term()
end
