defmodule Kitto do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [worker(__MODULE__, [], function: :start_server),
                worker(Kitto.Notifier, [])]

    Kitto.Runner.start_jobs
    Supervisor.start_link(children, [strategy: :one_for_one, name: Kitto.Supervisor])
  end

  def start_server do
    { :ok, _pid } = Plug.Adapters.Cowboy.http Kitto.Router, []
  end

  def root do
    Application.get_env :kitto, :root
  end
end

