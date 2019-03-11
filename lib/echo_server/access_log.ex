defmodule EchoServer.AccessLog do
  use Ecto.Schema

  schema "access_logs" do
    field(:url, :string)
    field(:body, :string)
    field(:requested_at, :utc_datetime)
  end

  def changeset(log, params \\ %{}) do
    log
    |> Ecto.Changeset.cast(params, [:url, :body, :requested_at])
    |> Ecto.Changeset.validate_required([:url, :requested_at])
  end
end
