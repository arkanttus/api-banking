defmodule ApiBankingWeb.TransactionController do
  use ApiBankingWeb, :controller
  alias ApiBanking.Transactions.Inputs
  alias ApiBanking.InputValidation

  def create_withdraw(conn, params) do
    with {:ok, input_params} <- InputValidation.cast_and_apply(params, Inputs.Withdraw),
         {:ok, transaction} <- ApiBanking.create_withdraw(input_params) do
      transaction
      |> format_transaction()
      |> send_json(conn, 200)
    else
      {:error, %{msg_error: msg_error}} ->
        %{type: "bad_request", description: "invalid_input", details: msg_error}
        |> send_json(conn, 400)

      {:error, :acc_not_exists} ->
        %{type: "not_found", description: "Account not found"}
        |> send_json(conn, 404)
    end
  end

  def create_transfer(conn, params) do
    with {:ok, input_params} <- InputValidation.cast_and_apply(params, Inputs.Transfer),
         {:ok, transaction} <- ApiBanking.create_transfer(input_params) do
      transaction
      |> format_transaction()
      |> send_json(conn, 200)
    else
      {:error, %{msg_error: msg_error}} ->
        %{type: "bad_request", description: "invalid_input", details: msg_error}
        |> send_json(conn, 400)

      {:error, :account_origin_not_exists} ->
        %{type: "not_found", description: "Account origin not found"}
        |> send_json(conn, 404)

      {:error, :account_target_not_exists} ->
        %{type: "not_found", description: "Account target not found"}
        |> send_json(conn, 404)
    end
  end

  def format_transaction(transaction) do
    acc = transaction.account_origin

    %{
      transaction_id: transaction.id,
      transaction_amount: transaction.amount,
      account: %{id: acc.id, account_code: acc.account_code, new_balance: acc.balance}
    }
  end

  def send_json(data, conn, status) do
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(status, Jason.encode!(data))
  end
end
