defmodule EchoServer.Handler do
  use GenServer
  require Logger

  def start_link(ref, socket, transport, _args) do
    peername =
      case :inet.peername(socket) do
        {:ok, {address, port}} -> "#{:inet.ntoa(address)}:#{port}"
        _ -> "unknwon"
      end

    state = %{
      ref: ref,
      transport: transport,
      socket: socket,
      peername: peername
    }

    GenServer.start_link(__MODULE__, state)
  end

  def init(state) do
    send(self(), :async_init)

    {:ok, state}
  end

  def handle_info(:async_init, state) do
    Logger.info("connection from #{state.peername}")
    Logger.debug("socket option #{get_socket_options(state.socket)}")

    :ranch_tcp = state.transport
    {:tcp, :tcp_closed, :tcp_error} = :ranch_tcp.messages()

    {:ok, _} = :ranch.handshake(state.ref)
    state.transport.setopts(state.socket, active: :once)

    {:noreply, state}
  end

  def handle_info({:tcp, _socket, data}, state) do
    Logger.info("data #{byte_size(data)} bytes from #{state.peername}")

    state.transport.send(state.socket, data)
    state.transport.setopts(state.socket, active: :once)

    {:noreply, state}
  end

  def handle_info({:tcp_closed, _socket}, state) do
    Logger.info("closed from #{state.peername}")

    {:stop, :normal, state}
  end

  def handle_info({:tcp_error, _socket, reason}, state) do
    Logger.info("error #{reason} from #{state.peername}")

    {:stop, :normal, state}
  end

  defp get_socket_options(socket) do
    option_names = [
      :active,
      :buffer,
      :delay_send,
      :deliver,
      :dontroute,
      :exit_on_close,
      :header,
      :high_msgq_watermark,
      :high_watermark,
      :keepalive,
      :linger,
      :low_msgq_watermark,
      :low_watermark,
      :mode,
      :nodelay,
      :packet,
      :packet_size,
      :priority,
      :recbuf,
      :reuseaddr,
      :send_timeout,
      :send_timeout_close,
      :show_econnreset,
      :sndbuf,
      :tos,
      :tclass,
      :ttl,
      :recvtos,
      :recvtclass,
      :recvttl,
      :ipv6_v6only
    ]

    case :inet.getopts(socket, option_names) do
      {:ok, options} -> inspect(options)
      _ -> "unknwon"
    end
  end
end
