defmodule ApiBanking.Transactions.CreateWithdraw do
  alias ApiBanking.Repo
  alias Ecto.Multi
  alias ApiBanking.Transactions.Schemas.Transaction
  alias ApiBanking.Accounts.Schemas.Account
  import Ecto.Query, only: [where: 3, lock: 2]

  require Logger

  def create_withdraw(struct) when is_struct(struct) do
    params = %{
      amount: struct.amount,
      description: struct.description,
      account_code: struct.account_code
    }

    create_withdraw(params)
  end

  def create_withdraw(params) do
    Logger.info("Creating a Transaction - Withdraw")

    with {:ok, transaction} <- withdraw_transaction(params) do
      {:ok, transaction}
    else
      {:error, :acc_not_exists} ->
        {:error, :acc_not_exists}

      {:error, %Ecto.Changeset{} = changeset} ->
        msg_error =
          Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
            Enum.reduce(opts, msg, fn {key, value}, acc ->
              String.replace(acc, "%{#{key}}", to_string(value))
            end)
          end)

        {:error, %{msg_error: msg_error}}
    end
  end

  defp withdraw_transaction(params) do
    %{account_code: account_code} = params

    Multi.new()
    |> Multi.run(:get_account, fn _repo, _change ->
      get_and_lock_account(account_code)
    end)
    |> Multi.run(:update_account, fn _, %{get_account: acc} ->
      update_account(acc, params)
    end)
    |> Multi.run(:create_transaction, fn _, %{get_account: acc} ->
      create_transaction(acc, params)
    end)
    |> Multi.run(:preload_data, fn _, %{create_transaction: trans} ->
      preload_data(trans)
    end)
    |> run_transaction()
  end

  defp get_and_lock_account(acc_code) do
    Account
    |> where([a], a.account_code == ^acc_code)
    |> lock("FOR UPDATE")
    |> Repo.one()
    |> case do
      %Account{} = acc -> {:ok, acc}
      nil -> {:error, :acc_not_exists}
    end
  end

  defp update_account(acc, %{amount: amount} = _params) do
    acc_params = %{balance: acc.balance - amount} |> IO.inspect()

    acc
    |> Account.changeset(acc_params)
    |> Repo.update()
  end

  defp create_transaction(acc, params) do
    %{
      amount: params.amount,
      type: "withdraw",
      description: params.description,
      account_origin_id: acc.id,
      account_target_id: acc.id
    }
    |> Transaction.changeset()
    |> Repo.insert()
  end

  defp preload_data(trans) do
    {:ok, Repo.preload(trans, :account_origin)}
  end

  defp run_transaction(multi) do
    case Repo.transaction(multi) do
      {:error, _operation, reason, _changes} -> {:error, reason}
      {:ok, %{preload_data: transaction}} -> {:ok, transaction}
    end
  end
end
