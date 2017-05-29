defmodule KittoTest do
  use ExUnit.Case

  import ExUnit.CaptureLog

  setup do
    path = Application.get_env :kitto, :root

    on_exit fn ->
      Application.put_env :kitto, :root, path
    end
  end

  test "#root when the :root config is set to a bitstring, it returns it" do
    path = "somewhere"
    Application.put_env :kitto, :root, path

    assert Kitto.root == path
  end

  test "#root when the :root config is set to :otp_app, returns the app_dir" do
    Application.put_env :kitto, :root, :otp_app

    assert Kitto.root == Application.app_dir(:kitto)
  end

  test "#root when the :root config is set to a non-bitstring, it raises error" do
    num = 42
    Application.put_env :kitto, :root, num

    assert catch_error(Kitto.root) == {:case_clause, num}
  end

  test "#root when the :root config is not set, it logs config info and exits" do
    Application.delete_env :kitto, :root

    assert capture_log(fn ->
      catch_exit(Kitto.root) == :shutdown
    end) =~ "config :root is nil."
  end

  test "#asset_server_host when the :assets_host is set, it returns it" do
    ip = "0.0.0.0"

    Application.put_env :kitto, :assets_host, ip

    assert Kitto.asset_server_host == ip
  end

  test "#asset_server_host when the :assets_host is not set, it returns the default" do
    Application.delete_env :kitto, :assets_host

    assert Kitto.asset_server_host == "127.0.0.1"
  end

  test "#asset_server_port when the :assets_port is set, it returns it" do
    port = 1337

    Application.put_env :kitto, :assets_port, port

    assert Kitto.asset_server_port == port
  end

  test "#asset_server_port when the :assets_port is not set, it returns the default" do
    Application.delete_env :kitto, :assets_port

    assert Kitto.asset_server_port == 8080
  end
end
