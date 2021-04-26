defmodule ApiBanking.Accounts.Statement do
  alias ApiBanking.Accounts.Schemas.Account
  alias ApiBanking.Transactions.Schemas.Transaction
  alias ApiBanking.Repo
  alias Ecto.Multi

  import Ecto.Query, only: [where: 3, order_by: 2]

  require Logger

  def get_statement(acc_id) do
    Logger.info("Print an account's bank statement")

    with {:ok, statement} <- statement_transaction(acc_id) do
      {:ok, statement}
    else
      {:error, :account_not_exists} ->
        {:error, :account_not_exists}
    end
  end

  defp statement_transaction(acc_id) do
    Multi.new()
    |> Multi.run(:get_account, fn _repo, _change ->
      get_account(acc_id)
    end)
    |> Multi.run(:get_transactions, fn _, %{get_account: acc} ->
      get_transactions(acc)
    end)
    |> Multi.run(:make_statement, fn _, %{get_transactions: trans, get_account: acc} ->
      make_statement(trans, acc)
    end)
    |> run_transaction()
  end

  defp get_account(acc_id) do
    Account
    |> Repo.get(acc_id)
    |> case do
      %Account{} = acc -> {:ok, acc}
      nil -> {:error, :account_not_exists}
    end
  end

  defp get_transactions(acc) do
    transactions =
      Transaction
      |> where([t], t.account_origin_id == ^acc.id or t.account_target_id == ^acc.id)
      |> order_by(desc: :inserted_at)
      |> Repo.all()

    {:ok, transactions}
  end

  defp make_statement(transactions, acc) do
    statement =
      Enum.map(transactions, fn trans ->
        make_statement_by_type(trans.type, acc.id, trans)
      end)

    {:ok, statement}
  end

  defp make_statement_by_type(type, acc_id, trans) do
    case type do
      "withdraw" ->
        %{operation: type, amount: trans.amount, date: trans.inserted_at, title: "Saque"}

      "transfer" ->
        if acc_id == trans.account_origin_id do
          %{
            operation: type,
            amount: trans.amount,
            transfer_to: trans.account_target_id,
            date: trans.inserted_at,
            title: "Transferência Enviada"
          }
        else
          %{
            operation: type,
            amount: trans.amount,
            transfer_from: trans.account_origin_id,
            date: trans.inserted_at,
            title: "Transferência Recebida"
          }
        end
    end
  end

  defp run_transaction(multi) do
    case Repo.transaction(multi) do
      {:error, _operation, reason, _changes} -> {:error, reason}
      {:ok, %{make_statement: statement}} -> {:ok, statement}
    end
  end
end
