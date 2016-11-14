defmodule Kitto.Plugs.Authentication do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _) do
    if authentication_required?(conn) && !authenticated?(conn) do
      conn |> send_resp(401, "Authorization required") |> halt
    else
      conn
    end
  end

  defp auth_token, do: Application.get_env(:kitto, :auth_token)

  defp authentication_required?(conn) do
    !!auth_token && validate_request(conn)
  end

  defp validate_request(conn) do
    conn.method == "POST" && conn.request_path =~ ~r/^\/?widgets/
  end

  defp authenticated?(conn) do
    auth_token == conn
      |> get_req_header("authentication")
      |> List.first
      |> to_string
      |> String.replace(~r/^Token\s/, "")
  end
end
