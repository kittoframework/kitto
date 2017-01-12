use Kitto.Job.DSL

defmodule Kitto.Jobs.Convergence do
  def new, do: Agent.start(fn -> 0 end)

  def points(pid, n \\ 10), do: points(pid, n, [point(pid)])
  defp points(_, n, acc) when length(acc) == n, do: acc
  defp points(pid, n, acc), do: points(pid, n, acc ++ [point(pid)])
  defp point(pid), do: %{x: pid |> next_point, y: random()}

  defp next_point(pid) do
    pid |> Agent.get_and_update(fn(n) -> next = n + 1; {next, next} end)
  end

  defp random, do: :rand.uniform * 100 |> Float.round
end

{:ok, convergence} = Kitto.Jobs.Convergence.new
points = &(&1 |> Kitto.Jobs.Convergence.points)

job :convergence, every: {2, :seconds} do
  broadcast! %{points: convergence |> points.()}
end
