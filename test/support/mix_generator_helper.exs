defmodule Kitto.MixGeneratorHelper do
  @moduledoc """
  Helpers to use when testing Mix tasks
  """
  import ExUnit.Assertions
  import Mock
  alias Kitto.Mix.GeneratorMock

  @mocks [create_file: &GeneratorMock.create_file/2,
          create_directory: &GeneratorMock.create_directory/1]

  @doc """
  Asserts that a file was created (with Mix.Generator.create_file/2) by running
  a Mix task.

  Arguments:

    * `file`: The file expected to be created. Can be a regex or string
    * `task`: Function which runs the task that is expected to create a file

  Usage:

      assert_creates_file ~r/my_job.ex/, fn() ->
        Mix.Kitto.Tasks.Gen.Job.run(["my_job"])
      end
  """
  def assert_creates_file(file, task) do
    with_mock Mix.Generator, @mocks do
      created_file = task.()
      match? = cond do
        is_binary(file) -> created_file == file
        Regex.regex?(file) -> created_file =~ file
      end
      assert match?, """
      Expected #{inspect file} to be created. Created #{created_file} instead.
      """
    end
  end

  @doc """
  Asserts that a directory was created( with Mix.Generator.create_directory/1)
  by running a Mix task.

  Arguments:

    * `dir`: The directory expected to be created. Can be a regex or string
    * `task`: Function which runs the task that is expected to create a directory

  Usage:

      assert_creates_directory ~r/my_widget/, fn() ->
        Mix.Kitto.Tasks.Gen.Widget.run(["my_widget"])
      end
  """
  def assert_creates_directory(dir, task) do
    with_mock Mix.Generator, @mocks do
      created_dir = task.()
      match? = cond do
        is_binary(dir) -> created_dir == dir
        Regex.regex?(dir) -> created_dir =~ dir
      end
      assert match?, """
      Expected #{inspect dir} to be created. Created #{created_dir} instead.
      """
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
