defmodule Kitto.TimeTest do
  use ExUnit.Case, async: true
  doctest Kitto.Time

  test "#mseconds(:day)", do: assert Kitto.Time.mseconds(:day) == 24 * 3600 * 1000
  test "#mseconds(:hour)", do: assert Kitto.Time.mseconds(:hour) == 3600 * 1000
  test "#mseconds(:minute)", do: assert Kitto.Time.mseconds(:minute) == 60 * 1000
  test "#mseconds(:second)", do: assert Kitto.Time.mseconds(:second) == 1000
  test "#mseconds(nil)", do: assert Kitto.Time.mseconds(nil) == nil

  test "#mseconds({n, :days})" do
    assert Kitto.Time.mseconds({2, :days}) == 2 * 24 * 3600 * 1000
  end

  test "#mseconds({1, :day})" do
    assert Kitto.Time.mseconds({1, :day}) == 1 * 24 * 3600 * 1000
  end

  test "#mseconds({n, :hours})" do
    assert Kitto.Time.mseconds({4, :hours}) == 4 * 3600 * 1000
  end

  test "#mseconds({1, :hour})" do
    assert Kitto.Time.mseconds({1, :hour}) == 1 * 3600 * 1000
  end

  test "#mseconds({n, :minutes})" do
    assert Kitto.Time.mseconds({5, :minutes}) == 5 * 60 * 1000
  end

  test "#mseconds({1, :minute})" do
    assert Kitto.Time.mseconds({1, :minutes}) == 1 * 60 * 1000
  end

  test "#mseconds({n, :seconds})" do
    assert Kitto.Time.mseconds({7, :seconds}) == 7 * 1000
  end

  test "#mseconds({n, :second})" do
    assert Kitto.Time.mseconds({1, :second}) == 1 * 1000
  end

  test "#mseconds({n, :milliseconds})" do
    assert Kitto.Time.mseconds({9, :milliseconds}) == 9
  end
end
