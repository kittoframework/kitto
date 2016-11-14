defmodule KittoTest do
  use ExUnit.Case

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
