defmodule ApiBanking.Transactions.CreateWithdraw do
  alias Ecto.Multi
  alias ApiBanking.Repo
  alias ApiBanking.Changesets
  alias ApiBanking.Accounts.Schemas.Account
  alias ApiBanking.Transactions.Inputs
  alias ApiBanking.Transactions.Schemas.Transaction
  import Ecto.Query, only: [where: 3, lock: 2]

  require Logger

  def create_withdraw(%Inputs.Withdraw{} = input_withdraw) do
    Logger.info("Creating a Transaction - Withdraw")

    params = %{
      amount: input_withdraw.amount,
      account_code: input_withdraw.account_code
    }

    with {:ok, transaction} <- withdraw_transaction(params) do
      {:ok, transaction}
    else
      {:error, :acc_not_exists} ->
        {:error, :acc_not_exists}

      {:error, %Ecto.Changeset{} = changeset} ->
        msg_error = Changesets.render_errors(changeset)
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
    |> Multi.run(:preload_data, fn _, %{create_transaction: trans, update_account: acc} ->
      preload_data(trans, acc)
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
    acc_params = %{balance: acc.balance - amount}

    acc
    |> Account.changeset(acc_params)
    |> Repo.update()
  end

  defp create_transaction(acc, params) do
    %{
      amount: params.amount,
      type: "withdraw",
      account_origin_id: acc.id,
      account_target_id: acc.id
    }
    |> Transaction.changeset()
    |> Repo.insert()
  end

  defp preload_data(trans, acc) do
    {:ok, Map.put(trans, :account_origin, acc)}
  end

  defp run_transaction(multi) do
    case Repo.transaction(multi) do
      {:error, _operation, reason, _changes} -> {:error, reason}
      {:ok, %{preload_data: transaction}} -> {:ok, transaction}
    end
  end
end
