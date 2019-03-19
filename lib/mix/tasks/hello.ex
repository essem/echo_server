defmodule Mix.Tasks.Hello do
  use Mix.Task

  import Mix.Generator

  @shortdoc "Simply runs the Hello.say/0 function"
  def run(_) do
    config_file = "config/local.exs"
    host = "genisys"
    namespace = "echo"
    service = "echo-db"

    HTTPoison.start()

    result =
      HTTPoison.get!("http://#{host}:8080/api/v1/namespaces/#{namespace}/services/#{service}")

    body = result.body |> Poison.decode!()
    port = List.first(body["spec"]["ports"])["nodePort"]

    opts = [port: port]

    case File.read(config_file) do
      {:ok, contents} ->
        Mix.shell().info([:green, "* updating ", :reset, config_file])

        File.write!(
          config_file,
          String.replace(contents, "use Mix.Config\n", config_template(opts))
        )

      {:error, _} ->
        create_file(config_file, config_template(opts))
    end
  end

  embed_template(:config, """
  use Mix.Config

  config :echo_server, EchoServer.Repo, port: <%= @port %>
  """)
end
