defmodule Kitto.Hook.Registry do
  @moduledoc """
  Stores hooks to access through the hook API.
  """

  use GenServer

  require Logger
  alias Kitto.Job.{Validator, Workspace}

  @doc """
  Starts the registry supervision tree
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name] || __MODULE__)
  end

  @doc false
  def init(opts) do
    pid = self()
    spawn fn -> load_hooks(pid) end

    {:ok, %{opts: opts, hooks: %{}}}
  end

  @doc """
  Registers a hook into the registry
  """
  def register(pid, hook), do: GenServer.call(pid, {:register, hook})

  @doc """
  Gets all hooks from the registry
  """
  def hooks(pid), do: GenServer.call(pid, {:hooks})

  def handle_call({:register, hook}, _from, state) do
    {:reply, {:ok, hook}, %{state | hooks: Map.put(state.hooks, hook[:name], hook)}}
  end

  def handle_call({:hooks}, _from, state), do: {:reply, state.hooks, state}

  defp load_hooks(pid), do: hook_files() |> Enum.each(&(load_hook(pid, &1)))

  defp load_hook(pid, file) do
    case Validator.valid?(file) do
      true -> Workspace.load_file(file, pid)
      false -> Logger.warn("Hook: #{file} contains syntax error(s) and will not be loaded.")
    end
  end

  defp hook_files do
    [Kitto.root(), hooks_dir(), "/**/*.{ex,exs}"] |> Path.join |> Path.wildcard
  end

  defp hooks_dir, do: Application.get_env(:kitto, :hooks_dir, "hooks")
end
