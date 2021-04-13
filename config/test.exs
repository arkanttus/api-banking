import Config

config :api_banking, ApiBanking.Repo,
  username: "postgres",
  password: "postgres",
  database: "api_banking_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  port: 5433,
  pool: Ecto.Adapters.SQL.Sandbox

config :api_banking_web, ApiBankingWeb.Endpoint,
  http: [port: 4002],
  server: false

config :logger, level: :warn
