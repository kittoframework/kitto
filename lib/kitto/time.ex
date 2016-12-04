defmodule Kitto.Time do
  @moduledoc """
  This module defines functions to handle time conversions.
  """

  @doc """
  Return the number of milliseconds for the given arguments.

  When a tuple is passed the first element is interpreted as the number to be converted
  in milliseconds and the second element as the time unit to convert from.

  An atom can also be used (one of `[:second, :minute, :hour, :day]`) for convenience.
  """
  def mseconds({n, :milliseconds}), do: n

  def mseconds({_n, duration}) when duration in [:second, :minute, :hour, :day] do
    apply __MODULE__, :mseconds, [duration]
  end

  def mseconds({n, duration}) when duration in [:seconds, :minutes, :hours] do
    apply :timer, duration, [n]
  end

  def mseconds({n, :days}), do: n * mseconds({24, :hours})

  def mseconds(nil), do: nil
  def mseconds(:second), do: mseconds({1, :seconds})
  def mseconds(:minute), do: mseconds({1, :minutes})
  def mseconds(:hour), do: mseconds({1, :hours})
  def mseconds(:day), do: mseconds({24, :hours})
end
