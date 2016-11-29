defmodule Kitto do
  @moduledoc """
  This is the documentation for the Kitto project.

  You can find documentation about developing with Kitto and configuration
  options at the [wiki](https://github.com/kittoframework/kitto#support)

  By default, Kitto applications depend on the following packages:

    * [Plug](https://hexdocs.pm/plug) - a specification and conveniences
      for composable modules in between web applications
    * [Poison](https://hexdocs.pm/poison) - an Elixir JSON library
  """

  use Application
  import Supervisor.Spec, warn: false
  require Logger

  @defaults %{ip: {127, 0, 0, 1}, port: 4000}

  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: Kitto.Supervisor]

    Supervisor.start_link(children(Mix.env), opts)
  end

  def start_server do
    Logger.info "Starting Kitto server, listening on #{ip_human(ip)}:#{port}"
    {:ok, _pid} = Plug.Adapters.Cowboy.http(Kitto.Router, [], ip: ip, port: port)
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
  defp port({:system, var}), do: var |> System.get_env |> Integer.parse |> elem(0)
  defp port(p) when is_integer(p), do: p
  defp port(_), do: @defaults.port

  defp children(:dev) do
    case Kitto.CodeReloader.reload_code? do
      true -> children(:all) ++ [worker(Kitto.CodeReloader, [[server: :runner]])]
      false -> children(:all)
    end
  end

  defp children(_env) do
    [supervisor(__MODULE__, [], function: :start_server),
     supervisor(Kitto.Notifier, []),
     worker(Kitto.StatsServer, []),
     worker(Kitto.Runner, [[name: :runner]])]
  end
end
