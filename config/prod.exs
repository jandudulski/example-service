use Mix.Config

config :service, [port: {:system, "SERVICE_PORT"},
                  token: {:system, "SERVICE_TOKEN"}]

