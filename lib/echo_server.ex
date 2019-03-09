defmodule EchoServer do
  use GenServer
  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(args) do
    Logger.info("Listen on port #{args.port}")

    opts = %{
      num_acceptors: 100,
      max_connections: :infinity,
      socket_opts: [
        port: args.port,
        backlog: 1024,
        nodelay: true
      ]
    }

    {:ok, _} = :ranch.start_listener(__MODULE__, :ranch_tcp, opts, EchoServer.Handler, [])
    Logger.info(inspect(:ranch.info(__MODULE__)))

    {:ok, %{}}
  end
end
