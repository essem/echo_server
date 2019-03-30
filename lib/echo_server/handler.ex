defmodule EchoServer.Handler do
  use GenServer
  require Logger

  def start_link(ref, socket, transport, _args) do
    state = %{
      ref: ref,
      transport: transport,
      socket: socket,
      peername: "unknown",
      health_check?: false
    }

    GenServer.start_link(__MODULE__, state)
  end

  def init(state) do
    send(self(), :async_init)

    {:ok, state}
  end

  def handle_info(:async_init, state) do
    :ranch_tcp = state.transport
    {:tcp, :tcp_closed, :tcp_error} = :ranch_tcp.messages()

    {:ok, _} = :ranch.handshake(state.ref)

    if Application.get_env(:echo_server, :use_proxy_protocol) do
      {:ok, data} = state.transport.recv(state.socket, 0, 1000)

      # TODO: prepare the case when data lenght is not enought for proxy header

      {:ok, result} = ProxyProtocol.parse(data)
      Logger.debug("proxy info #{inspect(result.proxy)}")

      peername = "#{result.proxy.src_address}:#{result.proxy.src_port}"
      health_check? = String.starts_with?(peername, "10.")

      state =
        state
        |> Map.put(:peername, "#{result.proxy.src_address}:#{result.proxy.src_port}")
        |> Map.put(:health_check?, health_check?)

      if !state.health_check? do
        Logger.info("connection from #{state.peername}")
        Logger.debug("socket option #{get_socket_options(state.socket)}")
      end

      if byte_size(result.buffer) > 0 do
        handle_info({:tcp, state.socket, data}, state)
      else
        state.transport.setopts(state.socket, active: :once)
        {:noreply, state}
      end
    else
      peername =
        case :inet.peername(state.socket) do
          {:ok, {address, port}} -> "#{:inet.ntoa(address)}:#{port}"
          _ -> "unknwon"
        end

      state = Map.put(state, :peername, peername)

      Logger.info("connection from #{state.peername}")
      Logger.debug("socket option #{get_socket_options(state.socket)}")

      state.transport.setopts(state.socket, active: :once)
      {:noreply, state}
    end
  end

  def handle_info({:tcp, _socket, data}, state) do
    Logger.info("data #{byte_size(data)} bytes from #{state.peername}")

    state.transport.send(state.socket, data)
    state.transport.setopts(state.socket, active: :once)

    {:noreply, state}
  end

  def handle_info({:tcp_closed, _socket}, state) do
    if !state.health_check? do
      Logger.info("closed from #{state.peername}")
    end

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
