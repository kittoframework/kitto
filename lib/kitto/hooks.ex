defmodule Kitto.Hooks do
  @moduledoc """
  Kitto Hooks enable an alternative to Jobs for feeding data into dashboards.
  Hooks enable remote services to push data into Kitto using webhooks.

  Just like jobs, hooks are loaded at runtime from the `hooks/` directory at
  the root of the application. Hooks can be defined as follows:

      use Kitto.Hooks.DSL
      hook :hello do
        {:ok, body, _} = read_body conn
        broadcast! :hello, body |> Poison.decode!
      end
  """

  def start_link do
    Agent.start_link(fn -> MapSet.new end, name: :hook_registrar)
  end

  def init(:ok) do
    load_hooks
  end

  def register(name, block) do
    hook = {name, block}
    Agent.update :hook_registrar, &MapSet.put(&1, hook)
  end

  def hooks do
    Agent.get(:hook_registrar, fn set -> Enum.into(set, []) end)
  end

  defp load_hooks, do: hook_files |> Enum.each(&Code.load_file/1)
  defp hook_files do
    [hook_dir, "**/*.{ex,exs}"] |> Path.join |> Path.wildcard
  end
  defp hook_dir, do: Application.get_env(:kitto, :hook_dir, default_hook_dir)
  defp default_hook_dir, do: [Kitto.root, "hooks"] |> Path.join
end
