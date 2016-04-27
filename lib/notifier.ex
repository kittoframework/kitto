defmodule Kitto.Notifier do
  def start_link, do: Agent.start_link(fn -> [] end, name: :notifier)

  def broadcast!(topic, data) do
    connections |> Enum.each(fn (conn) ->
      if !Process.alive?(conn), do: delete(conn)

      send conn, {:broadcast, {topic, data |> Map.merge(updated_at)}}
    end)
  end

  def register(conn) do
    notifier |> Agent.update(fn (connections) -> connections ++ [conn] end)

    conn
  end

  def delete(conn), do: notifier |> Agent.update(&(&1 |> List.delete(conn)))
  def connections, do: notifier |> Agent.get(&(&1))

  defp notifier, do: Process.whereis(:notifier)
  defp updated_at, do: %{updated_at: :os.system_time(:seconds)}
end
