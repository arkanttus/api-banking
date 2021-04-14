defmodule ApiBanking.TransactionsTest do
  use ApiBanking.DataCase, async: true

  alias ApiBanking.Transactions.Schemas.Transaction
  alias ApiBanking.Users.Schemas.User
  alias ApiBanking.Accounts.Schemas.Account

  setup do
    {:ok, user} =
      User.changeset(%{name: "lee", email: "lee@mail.com", password_hash: "#$%12345"})
      |> Repo.insert(on_conflict: :nothing)

    {:ok, user2} =
      User.changeset(%{name: "yasuo", email: "yasuo@mail.com", password_hash: "#$%12345"})
      |> Repo.insert(on_conflict: :nothing)

    {:ok, account} =
      Account.changeset(%{account_code: "12345", balance: 192_912, user: user.id})
      |> Repo.insert(on_conflict: :nothing)

    {:ok, account2} =
      Account.changeset(%{account_code: "424242", balance: 100, user: user2.id})
      |> Repo.insert(on_conflict: :nothing)

    {:ok, accounts: %{account: account.id, account2: account2.id}}
  end

  test "success create a withdraw with Transaction Schema", state do
    %{account: account} = state[:accounts]

    data = %{
      account_origin_id: account,
      type: "withdraw",
      description: "test",
      amount: 100,
      account_target_id: account
    }

    changeset = Transaction.changeset(data)

    assert {:ok, _} = Repo.insert(changeset, on_conflict: :nothing)
  end

  test "fail create a withdraw with amount less than 1", state do
    %{account: account} = state[:accounts]

    data = %{
      account_origin_id: account,
      type: "withdraw",
      description: "test fail",
      amount: 0,
      account_target_id: account
    }

    changeset = Transaction.changeset(data)

    assert %{valid?: false} = changeset
    assert {:error, _} = Repo.insert(changeset, on_conflict: :nothing)
  end

  test "success create a transfer with Transaction Schema", state do
    %{account: account, account2: account2} = state[:accounts]

    data = %{
      account_origin_id: account,
      type: "transfer",
      description: "test",
      amount: 500,
      account_target_id: account2
    }

    changeset = Transaction.changeset(data)

    assert {:ok, _} = Repo.insert(changeset, on_conflict: :nothing)
  end

  test "fail create a transfer with amount less than 1", state do
    %{account: account, account2: account2} = state[:accounts]

    data = %{
      account_origin_id: account,
      type: "transfer",
      description: "test",
      amount: -10,
      account_target_id: account2
    }

    changeset = Transaction.changeset(data)

    assert %{valid?: false} = changeset
    assert {:error, _} = Repo.insert(changeset, on_conflict: :nothing)
  end
end
