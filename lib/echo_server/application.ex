defmodule EchoServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    port = String.to_integer(System.get_env("ECHO_SERVER_PORT") || "8000")
    http_port = String.to_integer(System.get_env("ECHO_SERVER_HTTP_PORT") || "8080")

    children = [
      {EchoServer, %{port: port}},
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: EchoServer.Http.Router,
        options: [port: http_port]
      )
    ]

    opts = [strategy: :one_for_one, name: EchoServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
