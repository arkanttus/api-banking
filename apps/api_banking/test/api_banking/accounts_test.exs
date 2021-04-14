defmodule ApiBanking.AccountsTest do
  use ApiBanking.DataCase, async: true

  alias ApiBanking.Accounts.Schemas.Account
  alias ApiBanking.Users.Schemas.User

  setup do
    {:ok, user} =
      User.changeset(%{name: "lee", email: "lee@mail.com", password_hash: "#$%12345"})
      |> Repo.insert(on_conflict: :nothing)

    {:ok, user: user.id}
  end

  test "success create an account with Account Schema", state do
    data = %{
      account_code: "12345",
      balance: 1000,
      user: state[:user]
    }

    changeset = Account.changeset(data)

    assert {:ok, _} = Repo.insert(changeset, on_conflict: :nothing)
  end

  test "fail create an account with Account Schema", state do
    data = %{
      account_code: "12345",
      balance: -10,
      user: state[:user]
    }

    changeset = Account.changeset(data)

    assert %{valid?: false} = changeset
    assert {:error, _} = Repo.insert(changeset, on_conflict: :nothing)
  end
end
