defmodule ApiBankingWeb.TransactionControllerTest do
  use ApiBankingWeb.ConnCase, async: true

  describe "Withdraws" do
    setup [:create_account]

    test "success create a withdraw with valid input", %{conn: conn, account: acc} do
      %{"account_code" => acc_code, "id" => acc_id} = acc
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

    test "fail create a withdraw with amount less than 1", %{conn: conn, account: acc} do
      data = %{
        "account_code" => acc["account_code"],
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

    test "fail create a withdraw where amount is greater than balance",
         %{conn: conn, account: acc} do
      data = %{
        "account_code" => acc["account_code"],
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
  end

  describe "Transfers" do
    setup [:create_double_account]

    test "success create a transfer with valid input", %{conn: conn, account: acc, account2: acc2} do
      %{"account_code" => acc_code, "id" => acc_id} = acc
      %{"account_code" => acc_code2, "id" => acc_id2} = acc2
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

    test "fail create a transfer with amount less than 1", %{
      conn: conn,
      account: acc,
      account2: acc2
    } do
      data = %{
        "account_origin_code" => acc["account_code"],
        "account_target_code" => acc2["account_code"],
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
         %{conn: conn, account: acc, account2: acc2} do
      data = %{
        "account_origin_code" => acc["account_code"],
        "account_target_code" => acc2["account_code"],
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
  end

  defp create_account(_) do
    data = create_user_data()

    user = save_user(data)

    {:ok, account: user["account"]}
  end

  defp create_double_account(_) do
    data = create_user_data()
    data2 = create_user_data()

    user = save_user(data)
    user2 = save_user(data2)

    {:ok, account: user["account"], account2: user2["account"]}
  end

  defp save_user(data_user) do
    Phoenix.ConnTest.build_conn()
    |> post("/api/users", data_user)
    |> json_response(200)
  end

  defp create_user_data do
    email = "#{Ecto.UUID.generate()}@email.com"

    data = %{
      "name" => "cait",
      "email" => email,
      "email_confirmation" => email,
      "password" => "12345"
    }
  end
end
