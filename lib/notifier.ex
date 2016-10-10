defmodule Kitto.Notifier do
  use Supervisor

  def start_link, do: Supervisor.start_link(__MODULE__, :ok, name: :notifier_sup)

  def init(:ok) do
    children = [worker(__MODULE__, [], function: :start_connections_cache, id: make_ref),
                worker(__MODULE__, [], function: :start_notifier_cache, id: make_ref)]

    supervise(children, strategy: :one_for_one)
  end

  def start_connections_cache do
    Agent.start_link(fn -> [] end, name: :notifier_connections)
  end

  def start_notifier_cache, do: Agent.start_link(fn -> %{} end, name: :notifier_cache)

  def initial_broadcast!(pid) do
    cache |> Enum.each(fn ({topic, data}) -> broadcast!(pid, topic, data) end)
  end

  def broadcast!(topic, data) do
    cache(topic, data)

    connections |> Enum.each(fn (connection) -> broadcast!(connection, topic, data) end)
  end

  def broadcast!(pid, topic, data) do
    if !Process.alive?(pid), do: delete(pid)

    send pid, {:broadcast, {topic, data |> Map.merge(updated_at)}}
  end

  def register(conn) do
    notifier_connections |> Agent.update(fn (connections) -> connections ++ [conn] end)

    conn
  end

  def cache, do: notifier_cache |> Agent.get(&(&1))
  def clear_cache, do: notifier_cache |> Agent.update(fn (_) -> %{} end)

  def cache(topic, data) do
    notifier_cache |> Agent.update(fn (cache) -> Map.merge(cache, %{topic => data}) end)
  end

  def delete(conn), do: notifier_connections |> Agent.update(&(&1 |> List.delete(conn)))
  def connections, do: notifier_connections |> Agent.get(&(&1))

  defp notifier_connections, do: Process.whereis(:notifier_connections)
  defp notifier_cache, do: Process.whereis(:notifier_cache)
  defp updated_at, do: %{updated_at: :os.system_time(:seconds)}
end
