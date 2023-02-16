import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :task_handler, TaskHandlerWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "CbSYV5RpQlVrsBilgTn+9TVSmy5I7U0NRlLWAj502SjYFm+dvEhsQEBBR+C+iLkS",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
