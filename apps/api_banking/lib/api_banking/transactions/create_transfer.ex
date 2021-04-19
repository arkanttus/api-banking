defmodule ApiBanking.Transactions.CreateTransfer do
  alias Ecto.Multi
  alias ApiBanking.Repo
  alias ApiBanking.Changesets
  alias ApiBanking.Transactions.Inputs
  alias ApiBanking.Accounts.Schemas.Account
  alias ApiBanking.Transactions.Schemas.Transaction
  import Ecto.Query, only: [where: 3, lock: 2]

  require Logger

  def create_transfer(%Inputs.Transfer{} = struct) do
    Logger.info("Creating a Transaction - Transfer")

    params = %{
      amount: struct.amount,
      description: struct.description,
      account_origin_code: struct.account_origin_code,
      account_target_code: struct.account_target_code
    }

    with {:ok, transaction} <- transfer_transaction(params) do
      {:ok, transaction}
    else
      {:error, :account_origin_not_exists} ->
        {:error, :account_origin_not_exists}

      {:error, :account_target_not_exists} ->
        {:error, :account_target_not_exists}

      {:error, %Ecto.Changeset{} = changeset} ->
        msg_error = Changesets.render_errors(changeset)
        {:error, %{msg_error: msg_error}}
    end
  end

  defp transfer_transaction(params) do
    %{account_origin_code: account_origin_code, account_target_code: account_target_code} = params

    Multi.new()
    |> Multi.run(:get_account_origin, fn _repo, _change ->
      account_origin_code
      |> get_and_lock_account()
      |> case do
        %Account{} = acc -> {:ok, acc}
        nil -> {:error, :account_origin_not_exists}
      end
    end)
    |> Multi.run(:update_account_origin, fn _, %{get_account_origin: acc} ->
      balance = acc.balance - params.amount
      update_account(acc, balance)
    end)
    |> Multi.run(:get_account_target, fn _repo, _change ->
      account_target_code
      |> get_and_lock_account()
      |> case do
        %Account{} = acc -> {:ok, acc}
        nil -> {:error, :account_target_not_exists}
      end
    end)
    |> Multi.run(:update_account_target, fn _, %{get_account_target: acc} ->
      balance = acc.balance + params.amount
      update_account(acc, balance)
    end)
    |> Multi.run(
      :create_transaction,
      fn _, %{get_account_origin: acc_origin, get_account_target: acc_target} ->
        create_transaction(acc_origin, acc_target, params)
      end
    )
    |> Multi.run(
      :preload_data,
      fn _,
         %{
           create_transaction: trans,
           get_account_origin: acc_origin,
           get_account_target: acc_target
         } ->
        preload_data(trans, acc_origin, acc_target)
      end
    )
    |> run_transaction()
  end

  defp get_and_lock_account(acc_code) do
    Account
    |> where([a], a.account_code == ^acc_code)
    |> lock("FOR UPDATE")
    |> Repo.one()
  end

  defp update_account(acc, balance) do
    acc_params = %{balance: balance}

    acc
    |> Account.changeset(acc_params)
    |> Repo.update()
  end

  defp create_transaction(acc_origin, acc_target, params) do
    %{
      amount: params.amount,
      type: "transfer",
      description: params.description,
      account_origin_id: acc_origin.id,
      account_target_id: acc_target.id
    }
    |> Transaction.changeset()
    |> Repo.insert()
  end

  defp preload_data(trans, acc_origin, acc_target) do
    updated_trans =
      trans
      |> Map.put(:account_origin, acc_origin)
      |> Map.put(:account_target, acc_target)

    {:ok, updated_trans}
  end

  defp run_transaction(multi) do
    case Repo.transaction(multi) do
      {:error, _operation, reason, _changes} -> {:error, reason}
      {:ok, %{preload_data: transaction}} -> {:ok, transaction}
    end
  end
end
