defmodule RequestTest do
  use ExUnit.Case, async: true

  alias Jsonrpc.Request

  test "New request with method, params and or id" do
    assert Request.new(method: "test") == %Request{jsonrpc: "2.0", method: "test"}

    assert Request.new(method: "test", id: "1") == %Request{
             jsonrpc: "2.0",
             method: "test",
             id: "1"
           }

    assert Request.new(method: "test", id: 1) == %Request{jsonrpc: "2.0", method: "test", id: 1}

    assert Request.new(method: "test", params: 1, id: nil) == %Request{
             jsonrpc: "2.0",
             method: "test",
             params: 1,
             id: nil
           }
  end

  test "Request with invalid options" do
    assert_raise RuntimeError, "Method is not given", fn ->
      Request.new([])
    end

    assert_raise RuntimeError, "Method is invalid, should be a string", fn ->
      Request.new(method: [])
    end

    assert_raise RuntimeError, "ID is invalid: should be a string an integer or nil", fn ->
      Request.new(method: "test", id: 1.0)
    end
  end

  test "Request chaining" do
    requests =
      [method: "test", id: 1]
      |> Request.new()
      |> Request.new(method: "testTwo", id: 2)

    assert requests == [
             %Jsonrpc.Request{id: 1, jsonrpc: "2.0", method: "test", params: nil},
             %Jsonrpc.Request{id: 2, jsonrpc: "2.0", method: "testTwo", params: nil}
           ]

    requests =
      [method: "test", id: 1]
      |> Request.new()
      |> Request.new(method: "testTwo", id: 2)
      |> Request.new(method: "testThree", id: 3, params: ["1", "2", "3"])

    assert requests == [
             %Jsonrpc.Request{id: 1, jsonrpc: "2.0", method: "test", params: nil},
             %Jsonrpc.Request{id: 2, jsonrpc: "2.0", method: "testTwo", params: nil},
             %Jsonrpc.Request{id: 3, jsonrpc: "2.0", method: "testThree", params: ["1", "2", "3"]}
           ]
  end

  test "Auto ids" do
    requests =
      Request.new(method: "test")
      |> Request.new(method: "testTwo")
      |> Request.new(method: "testThree")

    assert Request.add_ids(requests) == [
             %Jsonrpc.Request{id: 1, jsonrpc: "2.0", method: "test", params: nil},
             %Jsonrpc.Request{id: 2, jsonrpc: "2.0", method: "testTwo", params: nil},
             %Jsonrpc.Request{id: 3, jsonrpc: "2.0", method: "testThree", params: nil}
           ]

    assert Request.add_ids(requests, 10) == [
             %Jsonrpc.Request{id: 10, jsonrpc: "2.0", method: "test", params: nil},
             %Jsonrpc.Request{id: 11, jsonrpc: "2.0", method: "testTwo", params: nil},
             %Jsonrpc.Request{id: 12, jsonrpc: "2.0", method: "testThree", params: nil}
           ]
  end
end