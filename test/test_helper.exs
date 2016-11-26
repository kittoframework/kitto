defmodule Kitto.TestHelper do
  import ExUnit.Assertions

  def atomify_map(map) do
    for {key, value} <- map, into: %{}, do: {String.to_atom(key), value}
  end

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
end

Mix.shell(Mix.Shell.Process)
ExUnit.configure(exclude: [pending: true])
ExUnit.start()
