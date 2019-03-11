defmodule EchoServer.Repo.Migrations.CreateAccessLogs do
  use Ecto.Migration

  def change do
    create table(:access_logs) do
      add(:url, :string)
      add(:body, :string)
      add(:requested_at, :utc_datetime)
    end
  end
end
