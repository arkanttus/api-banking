defmodule ApiBankingWeb.WithdrawControllerTest do
  use ApiBankingWeb.ConnCase, async: true

  setup [:create_user]

  test "success create a withdraw with valid input", %{conn: conn, user: user} do
    %{"account" => %{"account_code" => acc_code, "id" => acc_id}} = user
    amount = 50000
    new_balance = 100_000 - amount

    data = %{
      "account_code" => acc_code,
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
             |> post("/api/withdraw", data)
             |> json_response(200)
  end

  test "fail create a withdraw with amount less than 1", %{conn: conn, user: user} do
    data = %{
      "account_code" => user["account"]["account_code"],
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
             |> post("/api/withdraw", data)
             |> json_response(400)
  end

  test "fail create a withdraw where amount is greater than balance", %{conn: conn, user: user} do
    data = %{
      "account_code" => user["account"]["account_code"],
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
             |> post("/api/withdraw", data)
             |> json_response(400)
  end

  defp create_user(_) do
    data = %{
      "name" => "cait",
      "email" => "cait@mail.com",
      "email_confirmation" => "cait@mail.com",
      "password" => "12345"
    }

    conn = Phoenix.ConnTest.build_conn()

    user =
      conn
      |> post("/api/users", data)
      |> json_response(200)

    {:ok, user: user}
  end
end
