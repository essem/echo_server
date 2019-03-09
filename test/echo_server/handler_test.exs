defmodule HandlerTest do
  use ExUnit.Case

  setup do
    Application.ensure_all_started(:echo_server)

    port = String.to_integer(System.get_env("ECHO_SERVER_PORT") || "8000")
    opts = [:binary, packet: :raw, active: false]
    {:ok, socket} = :gen_tcp.connect('localhost', port, opts)

    %{socket: socket}
  end

  test "server interaction", %{socket: socket} do
    assert send_and_recv(socket, "a")
    assert send_and_recv(socket, "bb")
    assert send_and_recv(socket, "ccc")
    assert send_and_recv(socket, "dddd")
  end

  defp send_and_recv(socket, message) do
    :ok = :gen_tcp.send(socket, message)
    {:ok, data} = :gen_tcp.recv(socket, 0, 1000)
    message == data
  end
end
