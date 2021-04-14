defmodule ApiBanking.UsersTest do
  use ApiBanking.DataCase, async: true

  alias ApiBanking.Users.Schemas.User
  alias ApiBanking.Users.Inputs

  test "success create an user with User Schema" do
    data = %{
      name: "lee",
      email: "lee@mail.com",
      password_hash: "#$%12345"
    }

    assert {:ok, _user} = User.changeset(data) |> Repo.insert()
  end

  test "fail create an user with existing email" do
    email = "zed@mail.com"
    data = %{name: "lee", email: email, password_hash: "#$%12345"}

    Repo.insert!(%User{email: email})

    assert_raise Ecto.ConstraintError, fn ->
      User.changeset(data) |> Repo.insert()
    end
  end

  test "fail create an user with length name less than 3" do
    data = %{
      name: "le",
      email: "lee@mail.com",
      password_hash: "#$%12345"
    }

    changeset = User.changeset(data)

    assert %{valid?: false} = changeset
    assert {:error, _user} = Repo.insert(changeset)
  end
end
