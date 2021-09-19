defmodule MockBehaviourSystem do
  @callback os_time(unit :: atom()) :: unix_time :: integer()
end
