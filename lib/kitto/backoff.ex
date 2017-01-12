defmodule Kitto.Backoff do
  @moduledoc """
  Specification for a backoff module to be used with Kitto.
  """

  @callback succeed(atom) :: any
  @callback fail(atom):: any
  @callback backoff!(atom) :: any
end
