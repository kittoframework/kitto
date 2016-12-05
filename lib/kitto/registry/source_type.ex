defmodule Kitto.Registry.SourceType do
  @moduledoc """
  Primitive store for a data source type
  """

  @doc false
  def start_link do
    Agent.start_link(fn -> %{} end)
  end

  @doc """
  Gets all of the data sources from the registry
  """
  def get(source_type), do: Agent.get(source_type, &(&1))

  @doc """
  Get a data source from the source type's registry
  """
  def get(source_type, key), do: Agent.get(source_type, &Map.get(&1, key))

  @doc """
  Puts a data source into the registry
  """
  def put(source_type, key, value) do
    Agent.update(source_type, &Map.put(&1, key, value))
  end
end
