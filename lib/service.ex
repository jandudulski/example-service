defmodule Service do
  use Application

  require Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    port = to_port(Application.get_env(:service, :port))
    children = [
      Plug.Adapters.Cowboy.child_spec(:http, Service.Web, [], [port: port])
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
end
