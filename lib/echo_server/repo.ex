defmodule EchoServer.Repo do
  use Ecto.Repo,
    otp_app: :echo_server,
    adapter: Ecto.Adapters.MySQL
end
