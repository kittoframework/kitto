defmodule Kitto.Registry do
  @moduledoc """
  Registry for maintaining data source types. Data sources can either be defined
  as jobs, which pull in new data by polling or streaming, and hooks, which
  respond to HTTP requests providing new data for dashboards. See `Kitto.DSL`
  for how to build jobs and hooks.
  """

  use GenServer

  alias Kitto.Registry.SourceType

  @doc false
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, name: opts[:name] || __MODULE__)
  end

  ###
  # Client API
  ###

  @doc """
  Creates a new source type
  """
  def create(server, source_type) do
    GenServer.cast(server, {:create, source_type})
  end

  @doc """
  Looks up a source type in the registry
  """
  def lookup(server, source_type) do
    GenServer.call(server, {:lookup, source_type})
  end

  @doc """
  Registers a new job or hook into the registry
  """
  def register(server, source_type, name, definition, context \\ [])

  def register(server, :job, name, {options, block}, context) do
    {:ok, jobs} = lookup(server, :jobs)
    SourceType.put(jobs, name, options, block, context)
  end

  def register(server, :hook, name, {options, block}, context) do
    {:ok, hooks} = lookup(server, :hooks)
    SourceType.put(hooks, name, options, block, context)
  end

  @doc "Gets a list of all jobs from the registry"
  def jobs(server), do: data_sources(server, :jobs)
  @doc "Gets a list of all hooks from the registry"
  def hooks(server), do: data_sources(server, :hooks)

  @doc "Get's a specific job from the registry based on its name"
  def job(server, name), do: data_source(server, :jobs, name)
  @doc "Get's a speicifc hook from the registry based on its name"
  def hook(server, name), do: data_source(server, :hooks, name)

  defp data_sources(server, source_type_key) do
    {:ok, source_type} = lookup(server, source_type_key)
    SourceType.get(source_type)
  end

  defp data_source(server, source_type_name, data_source_name) do
    {:ok, source_type} = lookup(server, source_type_name)
    SourceType.get(source_type, data_source_name)
  end

  ###
  # Server
  ###

  @doc false
  def init(:ok) do
    {:ok, jobs} = SourceType.start_link
    {:ok, hooks} = SourceType.start_link

    {:ok, %{jobs: jobs, hooks: hooks}}
  end

  @doc false
  def handle_call({:lookup, name}, _from, source_types) do
    {:reply, Map.fetch(source_types, name), source_types}
  end

  @doc false
  def handle_cast({:create, name}, source_types) do
    if Map.has_key?(source_types, name) do
      {:noreply, source_types}
    else
      {:ok, source_type} = SourceType.start_link
      {:noreply, Map.put(source_types, name, source_type)}
    end
  end
end
