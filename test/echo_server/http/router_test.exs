defmodule RouterTest do
  use ExUnit.Case
  use Plug.Test

  @opts EchoServer.Http.Router.init([])

  test "returns hello world" do
    conn = conn(:get, "/hello")
    conn = EchoServer.Http.Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "world"
  end

  test "returns same data" do
    conn = conn(:post, "/echo", %{foo: 10})
    conn = EchoServer.Http.Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "{\"foo\":10}"
  end
end
