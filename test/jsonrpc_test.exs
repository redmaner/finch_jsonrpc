defmodule JsonrpcTest do
  use ExUnit.Case, async: true

  import Mox

  test "Jsonrpc call -> single request -> ok" do
    request = %Jsonrpc.Request{
      jsonrpc: "2.0",
      id: 69,
      method: "testSingleCall"
    }

    FinchMock
    |> expect(:request, 3, fn _req, _name, _opts ->
      body = ~s({"jsonrpc":"2.0","result":"Test was a success","id":69})
      {:ok, %Finch.Response{status: 200, body: body}}
    end)

    assert Jsonrpc.call_raw(request, name: :test, url: "http://localhost:8080") ==
             {:ok,
              %Jsonrpc.Response{error: nil, id: 69, jsonrpc: "2.0", result: "Test was a success"}}

    assert Jsonrpc.call(request, name: :test, url: "http://localhost:8080") ==
             {:ok, "Test was a success"}

    assert Jsonrpc.call!(request, name: :test, url: "http://localhost:8080") ==
             "Test was a success"
  end

  test "Jsonrpc call -> single request -> error" do
    request = %Jsonrpc.Request{
      jsonrpc: "2.0",
      id: 69,
      method: "testSingleCall"
    }

    FinchMock
    |> expect(:request, 3, fn _req, _name, _opts ->
      body =
        ~s({"jsonrpc":"2.0","error":{"code":-32602,"message":"Invalid request","data":"Expected params, got: []"},"id":69})

      {:ok, %Finch.Response{status: 200, body: body}}
    end)

    assert Jsonrpc.call_raw(request, name: :test, url: "http://localhost:8080") == {
             :error,
             %Jsonrpc.Response{
               error: %Jsonrpc.Error{
                 code: -32602,
                 data: "Expected params, got: []",
                 message: "Invalid request",
                 type: :invalid_params
               },
               id: 69,
               jsonrpc: "2.0",
               result: nil
             }
           }

    assert Jsonrpc.call(request, name: :test, url: "http://localhost:8080") ==
             {:error,
              %Jsonrpc.Error{
                code: -32602,
                data: "Expected params, got: []",
                message: "Invalid request",
                type: :invalid_params
              }}

    assert_raise Jsonrpc.Error.ResponseException, ~r/contained an error/, fn ->
      Jsonrpc.call!(request, name: :test, url: "http://localhost:8080")
    end
  end

  test "Jsonrpc call -> batch request -> ok" do
    request = [
      %Jsonrpc.Request{
        jsonrpc: "2.0",
        id: 69,
        method: "testBatchCallOne"
      },
      %Jsonrpc.Request{
        jsonrpc: "2.0",
        id: 420,
        method: "testBatchCallTwo"
      }
    ]

    FinchMock
    |> expect(:request, 3, fn _req, _name, _opts ->
      body =
        ~s([{"jsonrpc":"2.0","result":"Test was a success","id":69},{"jsonrpc":"2.0","result":"Test was a success","id":420}])

      {:ok, %Finch.Response{status: 200, body: body}}
    end)

    assert Jsonrpc.call_raw(request, name: :test, url: "http://localhost:8080") ==
             {:ok,
              [
                %Jsonrpc.Response{
                  error: nil,
                  id: 69,
                  jsonrpc: "2.0",
                  result: "Test was a success"
                },
                %Jsonrpc.Response{
                  error: nil,
                  id: 420,
                  jsonrpc: "2.0",
                  result: "Test was a success"
                }
              ]}

    assert Jsonrpc.call(request, name: :test, url: "http://localhost:8080") ==
             {:ok,
              [
                %Jsonrpc.Response{
                  error: nil,
                  id: 69,
                  jsonrpc: "2.0",
                  result: "Test was a success"
                },
                %Jsonrpc.Response{
                  error: nil,
                  id: 420,
                  jsonrpc: "2.0",
                  result: "Test was a success"
                }
              ]}

    assert Jsonrpc.call!(request, name: :test, url: "http://localhost:8080") ==
             [
               %Jsonrpc.Response{
                 error: nil,
                 id: 69,
                 jsonrpc: "2.0",
                 result: "Test was a success"
               },
               %Jsonrpc.Response{
                 error: nil,
                 id: 420,
                 jsonrpc: "2.0",
                 result: "Test was a success"
               }
             ]
  end

  test "Jsonrpc call -> batch request -> error" do
    request = [
      %Jsonrpc.Request{
        jsonrpc: "2.0",
        id: "69",
        method: "testBatchCallOne"
      },
      %Jsonrpc.Request{
        jsonrpc: "2.0",
        id: "420",
        method: "testBatchCallTwo"
      }
    ]

    FinchMock
    |> expect(:request, 3, fn _req, _name, _opts ->
      body =
        ~s([{"jsonrpc":"2.0","error":{"code":-32602,"message":"Invalid request","data":"Expected params, got: []"},"id":"69"},{"jsonrpc":"2.0","result":"Test was a success","id":"420"}])

      {:ok, %Finch.Response{status: 200, body: body}}
    end)

    assert Jsonrpc.call_raw(request, name: :test, url: "http://localhost:8080") ==
             {:error,
              [
                %Jsonrpc.Response{
                  error: %Jsonrpc.Error{
                    code: -32602,
                    data: "Expected params, got: []",
                    message: "Invalid request",
                    type: :invalid_params
                  },
                  id: "69",
                  jsonrpc: "2.0",
                  result: nil
                },
                %Jsonrpc.Response{
                  error: nil,
                  id: "420",
                  jsonrpc: "2.0",
                  result: "Test was a success"
                }
              ]}

    assert Jsonrpc.call(request, name: :test, url: "http://localhost:8080") ==
             {:error,
              [
                %Jsonrpc.Response{
                  error: %Jsonrpc.Error{
                    code: -32602,
                    data: "Expected params, got: []",
                    message: "Invalid request",
                    type: :invalid_params
                  },
                  id: "69",
                  jsonrpc: "2.0",
                  result: nil
                },
                %Jsonrpc.Response{
                  error: nil,
                  id: "420",
                  jsonrpc: "2.0",
                  result: "Test was a success"
                }
              ]}

    assert_raise Jsonrpc.Error.ResponseException, ~r/contained an error/, fn ->
      Jsonrpc.call!(request, name: :test, url: "http://localhost:8080")
    end
  end

  test "Error: timeout" do
    request = %Jsonrpc.Request{
      jsonrpc: "2.0",
      id: 69,
      method: "testSingleCall"
    }

    FinchMock
    |> expect(:request, 3, fn _request, _name, _opts ->
      {:error, :timeout}
    end)

    assert Jsonrpc.call_raw(request, name: :test, url: "http://localhost:8080") == {:error, :timeout}
    assert Jsonrpc.call(request, name: :test, url: "http://localhost:8080") == {:error, :timeout}

    assert_raise RuntimeError, fn ->
      Jsonrpc.call!(request, name: :test, url: "http://localhost:8080")
    end
  end

  test "Error: invalid json" do
    request = %Jsonrpc.Request{
      jsonrpc: "2.0",
      id: 69,
      method: "testSingleCall"
    }

    FinchMock
    |> expect(:request, 3, fn _request, _name, _opts ->
      {:ok, %Finch.Response{status: 200, body: "JSON go BRRRRRRR!"}}
    end)

    assert Jsonrpc.call_raw(request, name: :test, url: "http://localhost:8080") == {:error, "Could not decode response: no JSON: \"JSON go BRRRRRRR!\""}
    assert Jsonrpc.call(request, name: :test, url: "http://localhost:8080") == {:error, "Could not decode response: no JSON: \"JSON go BRRRRRRR!\""}

    assert_raise RuntimeError, fn ->
      Jsonrpc.call!(request, name: :test, url: "http://localhost:8080")
    end

  end
end
