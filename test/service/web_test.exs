defmodule Service.WebTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts Service.Web.init([])

  test "requires authorization header" do
    conn = conn(:get, "/")

    conn = Service.Web.call(conn, @opts)
    resp = conn.resp_body |> json_resp

    assert conn.status == 400
    assert resp["status"] == "Missing authorization header"
  end

  test "requires valid authorization token" do
    conn = conn(:get, "/") |> put_req_header("authorization", "invalid")

    conn = Service.Web.call(conn, @opts)
    resp = conn.resp_body |> json_resp

    assert conn.status == 401
    assert resp["status"] == "Incorrect token"
  end

  test "respond for authorized" do
    token = Application.get_env(:service, :token)
    conn = conn(:get, "/") |> put_req_header("authorization", token)

    conn = Service.Web.call(conn, @opts)
    resp = conn.resp_body |> json_resp

    assert conn.status == 200
    assert resp["status"] == "ok"
    assert resp["token"] == token
  end

  defp json_resp(resp) do
    resp |> Poison.decode!
  end
end
