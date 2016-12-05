defmodule Kitto.Registry do
  @moduledoc """
  Registry for maintaining data source types. Data sources can either be defined
  as jobs, which pull in new data by polling or streaming, and hooks, which
  respond to HTTP requests providing new data for dashboards. See `Kitto.DSL`
  for how to build jobs and hooks.
  """

  use GenServer

  alias Kitto.Registry.SourceType

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: :registry)
  end

  @doc """
  Creates a new source type
  """
  def create(server, name) do
    GenServer.cast(server, {:create, name})
  end

  @doc """
  Looks up a source type in the registry
  """
  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  @doc false
  def init(:ok) do
    {:ok, %{}}
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
