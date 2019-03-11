defmodule EchoServer.Http.Router do
  use Plug.Router
  require Ecto.Query

  plug(Plug.Logger)
  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  )

  plug(:dispatch)

  get "/hello" do
    send_resp(conn, 200, "world")
  end

  post "/echo" do
    body = Poison.encode!(conn.body_params)
    log = %EchoServer.AccessLog{}

    params = %{
      url: request_url(conn),
      body: body,
      requested_at: DateTime.utc_now()
    }

    changeset = EchoServer.AccessLog.changeset(log, params)
    {:ok, _log} = EchoServer.Repo.insert(changeset)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, body)
  end

  get "/logs" do
    rows =
      Ecto.Query.from(log in EchoServer.AccessLog,
        limit: 2
      )
      |> EchoServer.Repo.all()

    rows =
      Enum.map(rows, fn row ->
        row
        |> Map.from_struct()
        |> Map.delete(:__meta__)
      end)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(rows))
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end
