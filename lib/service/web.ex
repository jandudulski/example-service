defmodule Service.Web do
  use Plug.Router

  require Logger

  plug Plug.Logger
  plug :require_auth_header
  plug :verify_auth_header
  plug :match
  plug :dispatch

  get "/" do
    conn
    |> send_json_resp(200, %{ status: "ok", token: conn.assigns.token })
  end

  match _ do
    conn
    |> send_json_resp(404, %{ status: "Not found" })
  end

  defp require_auth_header(conn, _opts) do
    if get_req_header(conn, "authorization") == [] do
      conn |> send_json_resp(400, %{ status: "Missing authorization header" }) |> halt
    else
      conn
    end
  end

  defp verify_auth_header(conn, _opts) do
    if get_auth_header(conn) == token do
      conn |> assign(:token, token)
    else
      Logger.info "token: #{token}"
      Logger.info "send: #{get_auth_header(conn)}"
      conn |> send_json_resp(401, %{ status: "Incorrect token" }) |> halt
    end
  end

  defp get_auth_header(conn) do
    conn
    |> get_req_header("authorization")
    |> List.first
  end

  defp send_json_resp(conn, status, body) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Poison.encode!(body))
  end

  defp token do
    Application.fetch_env!(:service, :token)
  end
end
