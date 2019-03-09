defmodule EchoServer.Http.Router do
  use Plug.Router

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
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(conn.body_params))
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end
