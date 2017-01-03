defmodule Mix.Tasks.Kitto.Gen.DashboardTest do
  use ExUnit.Case, async: false
  import Kitto.MixGeneratorHelper

  setup do
    Mix.Task.clear
    :ok
  end

  test "fails when dashboard name not provided" do
    assert_raise Mix.Error, "No dashboard name provided", fn ->
      Mix.Tasks.Kitto.Gen.Dashboard.run([])
    end
  end

  test "creates dashboard" do
    assert_creates_file ~r/my_dash.html.eex/, fn ->
      Mix.Tasks.Kitto.Gen.Dashboard.run(["my_dash"])
    end
  end
end
