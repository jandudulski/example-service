defmodule Service do
  use Application

  require Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    port = to_port(Application.get_env(:service, :port))
    token = to_token(Application.get_env(:service, :token))

    children = [
      Plug.Adapters.Cowboy.child_spec(:http, Service.Web, [], [port: port, token: token])
    ]
    opts = [strategy: :one_for_one, name: Service.Supervisor]

    Supervisor.start_link(children, opts)
  end

  defp to_port(nil) do
    Logger.warn("Using default port for web")
    4000
  end
  defp to_port(value) when is_integer(value), do: value
  defp to_port(value) when is_binary(value), do: String.to_integer(value)
  defp to_port({:system, env_var}), do: to_port(System.get_env(env_var))

  defp to_token(nil) do
    Logger.warn("Using default token")
    "secret"
  end
  defp to_token(value) when is_binary(value), do: value
  defp to_token({:system, env_var}), do: to_token(System.get_env(env_var))
end
