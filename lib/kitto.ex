defmodule Kitto do
  use Application
  require Logger

  @defaults %{port: 4000}

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [supervisor(__MODULE__, [], function: :start_server),
                supervisor(Kitto.Notifier, []),
                worker(Kitto.StatsServer, []),
                supervisor(Kitto.Runner, [])]

    Supervisor.start_link(children, [strategy: :one_for_one, name: Kitto.Supervisor])
  end

  def start_server do
    Logger.info "Starting Kitto server on port #{port}"
    { :ok, _pid } = Plug.Adapters.Cowboy.http(Kitto.Router, [], port: port)
  end

  def root, do: Application.get_env :kitto, :root

  defp port, do: port(Application.get_env(:kitto, :port))
  defp port({:system, var}), do: System.get_env(var) |> Integer.parse |> elem(0)
  defp port(p) when is_integer(p), do: p
  defp port(_), do: @defaults.port
end
