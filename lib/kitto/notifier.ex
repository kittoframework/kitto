defmodule Kitto.Notifier do
  use Supervisor

  @doc """
  Starts the notifier supervision tree
  """
  def start_link, do: Supervisor.start_link(__MODULE__, :ok, name: :notifier_sup)

  def init(:ok) do
    children = [worker(__MODULE__, [], function: :start_connections_cache, id: make_ref),
                worker(__MODULE__, [], function: :start_notifier_cache, id: make_ref)]

    supervise(children, strategy: :one_for_one)
  end

  @doc """
  Starts the connections cache agent
  """
  def start_connections_cache do
    Agent.start_link(fn -> [] end, name: :notifier_connections)
  end

  @doc """
  Starts the notifier cache agent
  """
  def start_notifier_cache, do: Agent.start_link(fn -> %{} end, name: :notifier_cache)

  @doc """
  Every new SSE connection gets all the cached payloads for each job.
  The last broadcasted payload of each job is cached
  """
  def initial_broadcast!(pid) do
    cache |> Enum.each(fn ({topic, data}) -> broadcast!(pid, topic, data) end)
  end

  @doc """
  Emits a server-sent event to each of the active connections with the given
  topic and payload
  """
  def broadcast!(topic, data) do
    unless topic == "_kitto", do: cache(topic, data)

    connections |> Enum.each(fn (connection) -> broadcast!(connection, topic, data) end)
  end

  @doc """
  Emits a server-sent event to each of the active connections with the given
  topic and payload to a specific process
  """
  def broadcast!(pid, topic, data) do
    if !Process.alive?(pid), do: delete(pid)

    send pid, {:broadcast, {topic, data |> Map.merge(updated_at)}}
  end

  @doc """
  Updates the list of connections to use for broadcasting
  """
  def register(conn) do
    notifier_connections |> Agent.update(fn (connections) -> connections ++ [conn] end)

    conn
  end

  @doc """
  Returns cached broadcasts
  """
  def cache, do: notifier_cache |> Agent.get(&(&1))

  @doc """
  Resets the broadcast cache
  """
  def clear_cache, do: notifier_cache |> Agent.update(fn (_) -> %{} end)

  @doc """
  Caches the given payload with the key provided as the first argument
  """
  def cache(topic, data) do
    notifier_cache |> Agent.update(fn (cache) -> Map.merge(cache, %{topic => data}) end)
  end

  @doc """
  Removes a connection from the connections list
  """
  def delete(conn), do: notifier_connections |> Agent.update(&(&1 |> List.delete(conn)))

  @doc """
  Returns the registered connections
  """
  def connections, do: notifier_connections |> Agent.get(&(&1))

  defp notifier_connections, do: Process.whereis(:notifier_connections)
  defp notifier_cache, do: Process.whereis(:notifier_cache)
  defp updated_at, do: %{updated_at: :os.system_time(:seconds)}
end
