defmodule ApiBankingWeb.TransferControllerTest do
  use ApiBankingWeb.ConnCase, async: true

  setup [:create_user]

  test "success create a transfer with valid input", %{conn: conn, user: user, user2: user2} do
    %{"account" => %{"account_code" => acc_code, "id" => acc_id}} = user
    %{"account" => %{"account_code" => acc_code2, "id" => acc_id2}} = user2
    amount = 50000
    new_balance = 100_000 - amount

    data = %{
      "account_origin_code" => acc_code,
      "account_target_code" => acc_code2,
      "amount" => amount
    }

    assert %{
             "account" => %{
               "account_code" => acc_code,
               "id" => acc_id,
               "new_balance" => new_balance
             },
             "transaction_amount" => amount,
             "transaction_id" => _
           } =
             conn
             |> post("/api/transfer", data)
             |> json_response(200)
  end

  test "fail create a transfer with amount less than 1", %{conn: conn, user: user, user2: user2} do
    data = %{
      "account_origin_code" => user["account"]["account_code"],
      "account_target_code" => user2["account"]["account_code"],
      "amount" => -1
    }

    assert %{
             "description" => "invalid_input",
             "details" => %{
               "amount" => [
                 "must be greater than or equal to 1"
               ]
             },
             "type" => "bad_request"
           } =
             conn
             |> post("/api/transfer", data)
             |> json_response(400)
  end

  test "fail create a transfer where amount is greater than balance",
       %{conn: conn, user: user, user2: user2} do
    data = %{
      "account_origin_code" => user["account"]["account_code"],
      "account_target_code" => user2["account"]["account_code"],
      "amount" => 100_001
    }

    assert %{
             "description" => "invalid_input",
             "details" => %{
               "balance" => [
                 "Balance unavailable to peform this operation. The account balance cannot be negative."
               ]
             },
             "type" => "bad_request"
           } =
             conn
             |> post("/api/transfer", data)
             |> json_response(400)
  end

  defp create_user(_) do
    data = %{
      "name" => "cait",
      "email" => "cait@mail.com",
      "email_confirmation" => "cait@mail.com",
      "password" => "12345"
    }

    data2 = %{
      "name" => "cait2",
      "email" => "cait2@mail.com",
      "email_confirmation" => "cait2@mail.com",
      "password" => "12345"
    }

    conn = Phoenix.ConnTest.build_conn()

    user =
      conn
      |> post("/api/users", data)
      |> json_response(200)

    user2 =
      conn
      |> post("/api/users", data2)
      |> json_response(200)

    {:ok, user: user, user2: user2}
  end
end
