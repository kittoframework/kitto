defmodule Kitto.MixGeneratorHelper do
  @moduledoc """
  Helpers to use when testing Mix tasks
  """
  import ExUnit.Assertions
  import Mock
  alias Kitto.Mix.GeneratorMock

  def assert_creates_file(file, task) do
    with_mock Mix.Generator, [create_file: &GeneratorMock.create_file/2, create_directory: &GeneratorMock.create_directory/1] do
      created_file = task.()
      match? = cond do
        is_binary(file) -> created_file == file
        Regex.regex?(file) -> created_file =~ file
      end
      assert match?, "Expected #{inspect file} to be created. Created #{created_file} instead."
    end
  end

  def assert_creates_directory(dir, task) do
    with_mock Mix.Generator, [create_file: &GeneratorMock.create_file/2, create_directory: &GeneratorMock.create_directory/1] do
      created_dir = task.()
      match? = cond do
        is_binary(dir) -> created_dir == dir
        Regex.regex?(dir) -> created_dir =~ dir
      end
      assert match?, "Expected #{inspect dir} to be created. Created #{created_dir} instead."
    end
  end
end

defmodule Kitto.Mix.GeneratorMock do
  def create_directory(dir) do
    dir
  end

  def create_file(file, _contents) do
    file
  end
end
