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

  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: :hook_registry)
  end

  def init(:ok) do
    load_hooks
    {:ok, %{}}
  end

  @doc """
  Lookups a hook from the registry
  """
  def lookup(hook) do
    GenServer.call(:hook_registry, {:lookup, hook})
  end

  @doc """
  Registers a new hook into the registry
  """
  def register(name, block) do
    GenServer.cast(:hook_registry, {:register, name, block})
  end

  ### Callbacks

  def handle_call({:lookup, hook}, from, hooks) when is_atom(hook) do
    handle_call({:lookup, Atom.to_string(hook)}, from, hooks)
  end

  def handle_call({:lookup, hook}, _from, hooks) do
    {:reply, Map.fetch(hooks, hook), hooks}
  end


  def handle_cast({:register, hook, block}, hooks) when is_atom(hook) do
    handle_cast({:register, Atom.to_string(hook), block}, hooks)
  end

  def handle_cast({:register, hook, block}, hooks) do
    {:noreply, Map.put(hooks, hook, block)}
  end

  defp load_hooks do
    hook_files |> Enum.each(&Code.load_file/1)
  end
  defp hook_files do
    [hook_dir, "**/*.{ex,exs}"] |> Path.join |> Path.wildcard
  end
  defp hook_dir, do: Application.get_env(:kitto, :hook_dir, default_hook_dir)
  defp default_hook_dir, do: [Kitto.root, "hooks"] |> Path.join
end
