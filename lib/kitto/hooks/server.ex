defmodule Kitto.Hooks.Server do
  def start_link do
    Agent.start_link(fn -> MapSet.new end, name: __MODULE__)
  end

  def register(name, block) do
    hook = {name, block}
    Agent.update __MODULE__, &MapSet.put(&1, hook)
  end

  def hooks do
    Agent.get __MODULE__, fn set -> Enum.into(set, []) end
  end
end
