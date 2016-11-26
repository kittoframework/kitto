defmodule Mix.Tasks.Kitto.InstallTest do
  use ExUnit.Case, async: true
  import Mock
  import Kitto.TestHelper, except: [atomify_map: 1]

  @job_gist_response %{ files:
    %{"job.ex" => %{filename: "job.ex", language: "Elixir", content: "job"}}
  }

  @gist_response %{ files:
    %{
      "README.md" => %{filename: "README.md", language: "Markdown", content: "Title"},
      "number_job.ex" => %{filename: "number_job.ex", language: "Elixir", content: "job"},
      "number_job.scss" => %{filename: "number_job.scss", language: "SCSS", content: "style"},
      "number_job.js" => %{filename: "number_job.js", language: "JavaScript", content: "js"}
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
        Mix.Tasks.Kitto.Install.run(["--widget", "numbers", "--gist", "aaaa"])
        assert called HTTPoison.get!("https://api.github.com/gists/aaaa")
      end
      assert_received {:mix_shell, :error, ["Could not fetch the gist from GitHub: 404: Not Found"]}
    end
  end

  test "fails when the gist has widget but no `--widget` provided" do
    with_mock HTTPoison, [get!: mock_gist_with(200, @gist_response)] do
      assert_raise Mix.Error, fn ->
        Mix.Tasks.Kitto.Install.run(["--gist", "aaaa"])
        assert called HTTPoison.get!("https://api.github.com/gists/aaaa")
      end
    end
    assert_received {:mix_shell, :error, ["Please specify a widget directory using the --widget flag"]}
  end

  test "places all the files in the correct locations" do
    in_tmp "installes widgets and jobs", fn ->
      with_mock HTTPoison, [get!: mock_gist_with(200, @gist_response)] do
        Mix.Tasks.Kitto.Install.run(["--gist", "aaaa", "--widget", "number"])
        assert_file "widgets/number/number_job.js", fn file ->
          assert file =~ "js"
        end

        assert_file "widgets/number/number_job.scss", fn file ->
          assert file =~ "style"
        end

        assert_file "widgets/number/README.md", fn file ->
          assert file =~ "Title"
        end
        refute_file "widgets/number/number_job.ex"

        assert_file "jobs/number_job.ex", fn file ->
          assert file =~ "job"
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
