defmodule Kitto.DSLTest do
  use ExUnit.Case, async: true

  describe "jobs with blocks" do
    test "can define a job" do
      # pre_size = Enum.count Kitto.Registry.jobs
      defmodule JobWithBlock do
        use Kitto.DSL

        job :hello_world, every: {5, :seconds}, do: true
      end

      # assert Kitto.Registry.jobs == pre_size + 1
    end
  end

  describe "jobs with commands" do
  end

  describe "hooks" do

    test "includes Plug.Conn" do
      defmodule TestHook do
        use Kitto.DSL, type: :hook

        hook :hello_world, do: true
      end
    end
  end
end
