defmodule EchoServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  def start(_type, _args) do
    port = String.to_integer(System.get_env("ECHO_SERVER_PORT") || "8000")
    http_port = String.to_integer(System.get_env("ECHO_SERVER_HTTP_PORT") || "8080")

    # Override database config
    db_config =
      Keyword.merge(
        Application.get_env(:echo_server, EchoServer.Repo),
        [
          hostname: System.get_env("ECHO_SERVER_DB_HOST"),
          port: get_integer_env("ECHO_SERVER_DB_PORT")
        ]
        |> Enum.filter(fn {_, v} -> v != nil end)
      )

    Logger.info("DB config #{inspect(db_config)}")
    Application.put_env(:echo_server, EchoServer.Repo, db_config)

    children = [
      EchoServer.Repo,
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

  def get_integer_env(varname) do
    value = System.get_env(varname)

    if value == nil do
      nil
    else
      String.to_integer(value)
    end
  rescue
    _ -> nil
  end
end
