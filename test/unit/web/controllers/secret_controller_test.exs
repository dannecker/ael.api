defmodule Ael.Web.SecretControllerTest do
  use Ael.Web.ConnCase

  @create_attrs %{
    action: "GET",
    bucket: "declarations-dev",
    resource_id: "uuid",
    resource_name: "passport.jpg"
  }

  @invalid_attrs %{
    action: nil,
    bucket: nil,
    expires_at: nil,
    resource_id: nil,
    resource_name: nil
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "creates secret and renders secret when data is valid", %{conn: conn} do
    conn = post conn, secret_path(conn, :create), secret: @create_attrs
    assert  %{
      "action" => "GET",
      "bucket" => "declarations-dev",
      "resource_id" => "uuid",
      "resource_name" => "passport.jpg",
      "secret_url" => secret_url,
      "expires_at" => expires_at,
      "inserted_at" => inserted_at,
    } = json_response(conn, 201)["data"]

    {:ok, expires_at, 0} = DateTime.from_iso8601(expires_at)
    {:ok, inserted_at, 0} = DateTime.from_iso8601(inserted_at)

    assert :gt == DateTime.compare(expires_at, inserted_at)
    assert is_binary(secret_url)
  end

  test "does not create secret and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, secret_path(conn, :create), secret: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "validate entity success", %{conn: conn} do
    conn = post conn, secret_path(conn, :validate), %{
      "url" => "http://localhost:4040/declaration_signed_content",
      "rules" => [
        %{"field" => ["legal_entity", "edrpou"], "type" => "eq", "value" => "12345678"},
      ]
    }
    assert %{"is_valid" => true} = json_response(conn, 200)["data"]
  end

  test "validate entity fail", %{conn: conn} do
    conn = post conn, secret_path(conn, :validate), %{
      "url" => "http://localhost:4040/declaration_signed_content_not_valid",
      "rules" => [
        %{"field" => ["legal_entity", "edrpou"], "type" => "eq", "value" => "12345678"},
      ]
    }
    assert %{"is_valid" => false} = json_response(conn, 200)["data"]
  end
end
