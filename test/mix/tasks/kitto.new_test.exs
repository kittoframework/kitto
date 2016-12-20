Code.require_file "../../../installer/lib/kitto_new.ex", __DIR__

defmodule Mix.Tasks.Kitto.NewTest do
  use ExUnit.Case, async: false
  import Plug.Test
  import Kitto.FileAssertionHelper

  setup do
    Mix.Task.clear
    # The shell asks to install npm and mix deps.
    # We will politely say not.
    send self(), {:mix_shell_input, :yes?, false}
    :ok
  end

  test "when --version is provided, returns the current version" do
    Mix.Tasks.Kitto.New.run(["--version"])
    kitto_version = "Kitto v#{Mix.Project.config[:version]}"

    assert_received {:mix_shell, :info, [^kitto_version] }
  end

  test "fails when invalid application name is provided" do
    assert_raise Mix.Error, fn ->
      Mix.Tasks.Kitto.New.run(["dashboards@skidata"])
    end
  end

  test "fails when only providing a switch" do
    assert_raise Mix.Error, fn ->
      Mix.Tasks.Kitto.New.run(["-b"])
    end
  end

  describe "when creating a new project" do
    test "copies the files" do
      in_tmp 'bootstrap', fn ->
        Mix.Tasks.Kitto.New.run(["photo_dashboard"])

        assert_received {:mix_shell,
                         :info,
                         ["* creating photo_dashboard/config/config.exs"]}
      end
    end

    test "new project works" do
      in_tmp 'bootstrap', fn ->
        Mix.Tasks.Kitto.New.run(["photo_dashboard"])
      end

      path = Path.join(tmp_path, "bootstrap/photo_dashboard")
      in_project :photo_dashboard, path, fn _ ->
        Mix.Task.clear
        Mix.Task.run "compile", ["--no-deps-check"]
        Mix.shell.flush

        {:ok, _} = Application.ensure_all_started(:photo_dashboard)

        # Request the dashboard page to make sure the app responds correctly
        request = conn(:get, "/dashboards/sample")
        assert %Plug.Conn{status: 200} = Kitto.Router.call(request, [])
      end
    end
  end
end
