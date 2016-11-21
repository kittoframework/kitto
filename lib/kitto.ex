defmodule Kitto do
  use Application
  require Logger

  @defaults %{ip: {127, 0, 0, 1}, port: 4000}

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [supervisor(__MODULE__, [], function: :start_server),
                supervisor(Kitto.Notifier, []),
                worker(Kitto.StatsServer, []),
                supervisor(Kitto.Runner, [])]

    Supervisor.start_link(children, [strategy: :one_for_one, name: Kitto.Supervisor])
  end

  def start_server do
    Logger.info "Starting Kitto server, listening on #{ip_human(ip)}:#{port}"
    { :ok, _pid } = Plug.Adapters.Cowboy.http(Kitto.Router, [], ip: ip, port: port)
  end

  @doc """
  Returns the root path of the dashboard project
  """
  def root do
    case Application.get_env(:kitto, :root) do
      path when is_bitstring(path) -> path
      nil ->
        """
        Kitto config :root is nil.
        It should normally be set to Path.dirname(__DIR__) in config/config.exs
        """ |> Logger.error

        exit(:shutdown)
    end
  end

  @doc """
  Returns the binding ip of the assets watcher server
  """
  def asset_server_host, do: Application.get_env :kitto, :assets_host, "127.0.0.1"

  @doc """
  Returns the binding port of the assets watcher server
  """
  def asset_server_port, do: Application.get_env :kitto, :assets_port, 8080

  @doc """
  Returns whether the asset server should be used or not
  """
  def asset_server_enabled?, do: Mix.env == :dev

  defp ip, do: ip(Application.get_env(:kitto, :ip, @defaults.ip))
  defp ip({:system, var}) do
    case System.get_env(var) do
      nil ->
        Logger.error "Configured binding ip via #{var} but no value is set"
        exit(:shutdown)
      address -> address
        |> String.split(".")
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple
    end
  end
  defp ip(address) when is_tuple(address), do: address
  defp ip(_), do: @defaults.ip
  defp ip_human(tup), do: tup |> Tuple.to_list |> Enum.join(".")

  defp port, do: port(Application.get_env(:kitto, :port))
  defp port({:system, var}), do: System.get_env(var) |> Integer.parse |> elem(0)
  defp port(p) when is_integer(p), do: p
  defp port(_), do: @defaults.port
end
