defmodule Kitto.Runner do
  def start_jobs do
    job_files |> Enum.each(&Code.eval_file/1)
  end

  defp job_files do
    Path.wildcard Path.join(System.cwd, "jobs/**/*.{ex,exs}")
  end
end
