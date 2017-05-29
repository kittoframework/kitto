defmodule Kitto.Job.DSLTest do
  use ExUnit.Case, async: true
  use Kitto.Job.DSL

  test """
  Calls to broadcast!/1 are transformed to broadcast!/2 using the job name as
  broadcast topic
  """ do
    ast = quote do
      job :valid, every: :second do
        broadcast! %{}
      end
    end

    expanded_ast = Macro.expand(ast, __ENV__) |> Macro.to_string

    assert expanded_ast |> String.match?(~r/broadcast!\(:valid, %{}\) end\)/)
  end

  test "Converts job name to atom if it's a string" do
    ast = quote do
      job "valid", every: :second do
        broadcast! :valid, %{}
      end
    end

    expanded_ast = Macro.expand(ast, __ENV__) |> Macro.to_string

    assert expanded_ast =~ ~r/Job.register\(binding\(\)\[:runner_server\], :valid/
  end

  test "When piping data to broadcast!, railroading is enabled using the job name as broadcast topic" do
    ast = quote do
      job :valid, every: :second do
        Weather.in(:london)
        |> broadcast!
      end
    end

    expanded_ast = Macro.expand(ast, __ENV__) |> Macro.to_string

    assert expanded_ast |> String.match?(~r/Weather.in\(:london\) |> broadcast!\(:valid\) end\)/)
  end

  test "When piping data to broadcast!(), railroading is enabled using the job name as broadcast topic" do
    ast = quote do
      job :valid, every: :second do
        Weather.in(:london)
        |> broadcast!()
      end
    end
    
    expanded_ast = Macro.expand(ast, __ENV__) |> Macro.to_string
    
    assert expanded_ast |> String.match?(~r/Weather.in\(:london\) |> broadcast!\(:valid\) end\)/)
  end

  test "When piping data to broadcast! specifying job name, no transformations are made" do
    ast = quote do
      job :valid, every: :second do
        Weather.in(:london)
        |> broadcast!(:london_weather)
      end
    end

    expanded_ast = Macro.expand(ast, __ENV__) |> Macro.to_string

    assert expanded_ast |> String.match?(~r/Weather.in\(:london\) |> broadcast!\(:london_weather\) end\)/)
  end
end
