# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :echo_server, EchoServer.Repo,
  database: "echo",
  username: "devuser",
  password: "devpass",
  hostname: "127.0.0.1",
  port: 3306

config :echo_server, ecto_repos: [EchoServer.Repo]

config :echo_server, :kubernetes,
  master_host: "kube-master",
  namespace: "echo",
  service: "echo-db"

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# third-party users, it should be done in your "mix.exs" file.

# You can configure your application as:
#
#     config :echo_server, key: :value
#
# and access this configuration in your application as:
#
#     Application.get_env(:echo_server, :key)
#
# You can also configure a third-party app:

config :logger, level: :info
config :logger, :console, format: "$time $metadata[$level] $levelpad$message\n"

config_dir = Path.dirname(__ENV__.file)

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).

if File.exists?(Path.join(config_dir, "#{Mix.env()}.exs")) do
  import_config "#{Mix.env()}.exs"
end

# Most priority config file "local.exs"
# This file is for personal setting.
# Do not add it to source control system

config_dir = Path.dirname(__ENV__.file)

if File.exists?(Path.join(config_dir, "local.exs")) do
  import_config "local.exs"
end
