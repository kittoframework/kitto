defmodule Kitto.FileAssertionHelper do
  @moduledoc """
  Original code from the Phoenix Framework
  https://github.com/phoenixframework/phoenix/blob/master/installer/test/mix_helper.exs
  """
  import ExUnit.Assertions
  import ExUnit.CaptureIO

  def assert_file(file) do
    assert File.regular?(file), "Expected #{file} to exist, but does not"
  end

  def assert_file(file, match) do
    cond do
      is_list(match) ->
        assert_file file, &(Enum.each(match, fn(m) -> assert &1 =~ m end))
      is_binary(match) or Regex.regex?(match) ->
        assert_file file, &(assert &1 =~ match)
      is_function(match, 1) ->
        assert_file(file)
        match.(File.read!(file))
    end
  end

  def refute_file(file) do
    refute File.regular?(file), "Expected #{file} to not exist, but it does"
  end

  def tmp_path, do: System.tmp_dir()

  def in_tmp(which, function) do
    path = Path.join(tmp_path(), which)
    File.rm_rf! path
    File.mkdir_p! path
    File.cd! path, function
  end

  def in_project(app, path, fun) do
    %{name: name, file: file} = Mix.Project.pop

    try do
      capture_io :stderr, fn -> Mix.Project.in_project(app, path, [], fun) end
    after
      Mix.Project.push(name, file)
    end
  end
end
