defmodule Kitto.Time do
  @doc """
  Return the number of milliseconds when for n seconds
  """
  def mseconds({n, :milliseconds}), do: n

  @doc """
  Return the number of milliseconds when for n seconds
  """
  def mseconds({n, :seconds}), do: :timer.seconds(n)

  @doc """
  Return the number of milliseconds when for n minutes
  """
  def mseconds({n, :minutes}), do: :timer.minutes(n)

  @doc """
  Return the number of milliseconds when for n hours
  """
  def mseconds({n, :hours}), do: :timer.hours(n)
  @doc """
  Return the number of milliseconds when for n days
  """
  def mseconds({n, :days}), do: n * mseconds({24, :hours})

  @doc """
  Return the number of milliseconds when nil is passed
  """
  def mseconds(nil), do: nil

  @doc """
  Return the number of milliseconds in a second
  """
  def mseconds(:second), do: mseconds({1, :seconds})

  @doc """
  Return the number of milliseconds in a minute
  """
  def mseconds(:minute), do: mseconds({1, :minutes})

  @doc """
  Return the number of milliseconds in an hour
  """
  def mseconds(:hour), do: mseconds({1, :hours})

  @doc """
  Return the number of milliseconds in a day
  """
  def mseconds(:day), do: mseconds({24, :hours})
end
