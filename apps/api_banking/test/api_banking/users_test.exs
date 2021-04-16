defmodule ApiBanking.UsersTest do
  use ApiBanking.DataCase, async: true

  alias ApiBanking.Users.Schemas.User
  alias ApiBanking.Users.Inputs
  alias ApiBanking.InputValidation

  test "success create an user with valid input" do
    email = "cait@mail.com"
    data = %{name: "cait", email: email, email_confirmation: email, password: "12345"}

    assert {:ok, input_changeset} = InputValidation.cast_and_apply(data, Inputs.Create)
    assert {:ok, _user} = ApiBanking.create_user(input_changeset)
  end

  test "fail create an user with existing email" do
    email = "troll@mail.com"
    data = %{name: "lee", email: email, email_confirmation: email, password: "12345"}

    Repo.insert!(%User{email: email})

    assert {:ok, input_changeset} = InputValidation.cast_and_apply(data, Inputs.Create)

    assert {:error, :email_conflict} = ApiBanking.create_user(input_changeset)
  end

  test "fail create an user with length name less than 3" do
    email = "zed@mail.com"
    data = %{name: "ze", email: email, email_confirmation: email, password: "12345"}

    assert {:error, %{msg_error: _}} = InputValidation.cast_and_apply(data, Inputs.Create)
  end
end
