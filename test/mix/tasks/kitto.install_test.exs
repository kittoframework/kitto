defmodule Mix.Tasks.Kitto.InstallTest do
  use ExUnit.Case, async: false
  import Mock
  import Kitto.FileAssertionHelper

  @css_gist_response %{
    files: %{"number.scss" => %{filename: "number.scss",
                                language: "SCSS",
                                content: "style"}}}

  @gist_response %{
    files: %{
      "README.md" => %{filename: "README.md", language: "Markdown", content: "Title"},
      "number.ex" => %{filename: "number.ex", language: "Elixir", content: "lib"},
      "number.exs" => %{filename: "number.exs", language: "Elixir", content: "job"},
      "number.scss" => %{filename: "number.scss", language: "SCSS", content: "style"},
      "number.js" => %{filename: "number.js", language: "JavaScript", content: "js"}
    }
  }

  setup do
    Mix.Task.clear
    :ok
  end

  test "fails when `--gist` is not provided" do
    Mix.Tasks.Kitto.Install.run(["--widget", "numbers"])

    assert_received {:mix_shell, :error, ["Unsupported arguments"]}
  end

  test "fails when the gist is not found" do
    with_mock HTTPoison, [get!: mock_gist_with(404, %{message: "Not Found"})] do

      assert_raise Mix.Error, fn ->
        Mix.Tasks.Kitto.Install.run(["--widget", "numbers", "--gist", "0209a4a80cee78"])

        assert called HTTPoison.get!("https://api.github.com/gists/0209a4a80cee78")
      end

      assert_received {:mix_shell, :error, ["Could not fetch the gist from GitHub: 404: Not Found"]}
    end
  end

  test "fails when no widget directory is specified or found" do
    with_mock HTTPoison, [get!: mock_gist_with(200, @css_gist_response)] do

      assert_raise Mix.Error, fn ->
        Mix.Tasks.Kitto.Install.run(["--gist", "0209a4a80cee78"])

        assert called HTTPoison.get!("https://api.github.com/gists/0209a4a80cee78")
      end
    end

    assert_received {:mix_shell, :error, ["Please specify a widget directory using the --widget flag"]}
  end

  test "places all the files in the correct locations" do
    in_tmp "installs widgets and jobs", fn ->
      with_mock HTTPoison, [get!: mock_gist_with(200, @gist_response)] do
        Mix.Tasks.Kitto.Install.run(["--gist", "0209a4a80cee78"])

        assert_file "widgets/number/number.js", fn contents ->
          assert contents =~ "js"
        end

        assert_file "widgets/number/number.scss", fn contents ->
          assert contents =~ "style"
        end

        assert_file "widgets/number/README.md", fn contents ->
          assert contents =~ "Title"
        end
        refute_file "widgets/number/number.exs"

        assert_file "lib/number.ex", fn contents ->
          assert contents =~ "lib"
        end

        assert_file "jobs/number.exs", fn contents ->
          assert contents =~ "job"
        end
      end
    end
  end

  test "uses the widget overwrite for the widget directory" do
    in_tmp "installs widgets and jobs using overwrite", fn ->
      with_mock HTTPoison, [get!: mock_gist_with(200, @gist_response)] do
        Mix.Tasks.Kitto.Install.run(["--gist", "0209a4a80cee78", "--widget", "overwrite"])

        assert_file "widgets/overwrite/number.js", fn contents ->
          assert contents =~ "js"
        end

        assert_file "widgets/overwrite/number.scss", fn contents ->
          assert contents =~ "style"
        end

        assert_file "widgets/overwrite/README.md", fn contents ->
          assert contents =~ "Title"
        end
        refute_file "widgets/overwrite/number.exs"

        assert_file "jobs/number.exs", fn contents ->
          assert contents =~ "job"
        end
      end
    end
  end

  def mock_gist_with(status_code, body) do
    fn (_url) ->
      %HTTPoison.Response{status_code: status_code, body: Poison.encode!(body)}
    end
  end
end
