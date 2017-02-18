defmodule Kitto.Plugs.Authentication do
  @moduledoc """
  Defines authentication logic for routes that require it.
  Authentication uses token based auth with the Authentication header.

  ## Setting up authentication:

  To configure the dashboard with authentication, add the expected auth token to
  your application's config:

      # config/config.exs
      config :kitto, auth_token: "asecret"

  ## Authenticating requests

  To authenticate requests that require it, pass the auth token in the
  Authentication header of the request:

      Authentication: Token asecret

  An example cURL request to reload all dashboards with authentication:

      $ curl -H "Authentication: Token asecret" -X POST http://localhost:4000/dashboards

  ## Marking routes as authenticated

  When adding new routes, to mark them as authenticated, add the `authenticated` key
  to the route's private config:

  get "my/authenticated/route", private: %{authenticated: true} do
    # Process normal request
  end
  """

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _) do
    if authentication_required?(conn) && !authenticated?(conn) do
      conn |> send_resp(401, "Authorization required") |> halt
    else
      conn
    end
  end

  defp authentication_required?(conn) do
    !!auth_token() && conn.private[:authenticated]
  end

  defp authenticated?(conn) do
    auth_token() == conn
      |> get_req_header("authentication")
      |> List.first
      |> to_string
      |> String.replace(~r/^Token\s/, "")
  end

  defp auth_token, do: Application.get_env(:kitto, :auth_token)
end
