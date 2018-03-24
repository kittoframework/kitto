defmodule Kitto.BackoffServer do
  @moduledoc """
  Module responsible for keeping and applying a backoff value
  for a given atom.

  ### Configuration

  * `:job_min_backoff` - The minimum time in milliseconds to backoff upon failure
  * `:job_max_backoff` - The maximum time in milliseconds to backoff upon failure
  """

  @behaviour Kitto.Backoff

  use GenServer
  use Bitwise

  alias Kitto.Time

  @server __MODULE__
  @minval Time.mseconds(:second)
  @maxval Time.mseconds({5, :minutes})

  @doc false
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name] || __MODULE__)
  end

  @doc false
  def init(_), do: {:ok, %{}}

  @doc """
  Resets the backoff for the given atom to 0
  """
  @spec succeed(atom()) :: atom()
  def succeed(name), do: set(name, 0)

  @doc """
  Increments the backoff value for the provided atom up to the
  configured maximum value.
  """
  def fail(name) do
    case get(name) do
      nil -> set(name, min(minval(), maxval()))
      0 -> set(name, min(minval(), maxval()))
      val -> set(name, min(val <<< 1, maxval()))
    end
  end

  @doc """
  Makes the calling process sleep for the accumulated backoff time
  for the given atom
  """
  @spec backoff!(atom()) :: :nop | :ok
  def backoff!(name), do: backoff!(name, name |> get)
  defp backoff!(_name, val) when is_nil(val) or val == 0, do: :nop
  defp backoff!(_name, val), do: :timer.sleep(val)

  @spec get(atom()) :: nil | non_neg_integer()
  def get(name), do: GenServer.call(@server, {:get, name})

  @spec reset() :: nil
  def reset, do: GenServer.call(@server, :reset)

  ### Callbacks
  def handle_call(:reset, _from, _state), do: {:reply, nil, %{}}
  def handle_call({:get, name}, _from, state), do: {:reply, state[name], state}

  def handle_call({:set, name, value}, _from, state) do
    {:reply, name, put_in(state[name], value)}
  end

  defp set(name, value), do: GenServer.call(@server, {:set, name, value})
  defp minval, do: Application.get_env(:kitto, :job_min_backoff, @minval)
  defp maxval, do: Application.get_env(:kitto, :job_max_backoff, @maxval)
end
