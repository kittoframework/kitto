defmodule Kitto.Job.Validator do
  @moduledoc """
  Performs basic validations on job files.
  """

  @doc """
  Returns true if the file specified contains no syntax errors,
  false otherwise
  """
  def valid?(file), do: file |> File.read!() |> syntax_valid?

  defp syntax_valid?(str) when is_bitstring(str) do
    str |> Code.string_to_quoted() |> syntax_valid?
  end

  defp syntax_valid?({:ok, _}), do: true
  defp syntax_valid?({:error, _}), do: false
end
