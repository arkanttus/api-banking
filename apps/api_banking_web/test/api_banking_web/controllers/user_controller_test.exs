defmodule ApiBankingWeb.UserControllerTest do
  use ApiBankingWeb.ConnCase, async: true

  alias ApiBanking.Users.Schemas.User
  alias ApiBanking.Repo

  test "success create an user with valid input", ctx do
    email = "cait@mail.com"

    data = %{
      "name" => "cait",
      "email" => email,
      "email_confirmation" => email,
      "password" => "12345"
    }

    assert %{
             "id" => _,
             "email" => ^email,
             "name" => "cait",
             "account" => %{"account_code" => _, "balance" => 100_000, "id" => _}
           } =
             ctx.conn
             |> post("/api/users", data)
             |> json_response(200)
  end

  @tag capture_log: true
  test "fail create an user with existing email", ctx do
    email = "troll@mail.com"

    data = %{
      "name" => "lee",
      "email" => email,
      "email_confirmation" => email,
      "password" => "12345"
    }

    Repo.insert!(%User{email: email})

    assert ctx.conn
           |> post("/api/users", data)
           |> json_response(400) == %{
             "description" => "Email already exists",
             "type" => "conflict"
           }
  end

  test "fail create an user with length name less than 3", ctx do
    email = "zed@mail.com"

    data = %{
      "name" => "ze",
      "email" => email,
      "email_confirmation" => email,
      "password" => "12345"
    }

    assert ctx.conn
           |> post("/api/users", data)
           |> json_response(400) == %{
             "description" => "invalid_input",
             "type" => "bad_request",
             "details" => %{"name" => ["should be at least 3 character(s)"]}
           }
  end
end
