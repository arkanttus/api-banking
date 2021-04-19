defmodule ApiBanking.Users.Create do
  alias Ecto.Multi
  alias ApiBanking.Repo
  alias ApiBanking.Changesets
  alias ApiBanking.Users.Inputs
  alias ApiBanking.Users.Schemas.User
  alias ApiBanking.Accounts.Schemas.Account

  require Logger

  def create_user(%Inputs.Create{} = input_create) do
    Logger.info("Inserting new User")

    params = %{
      email: input_create.email,
      name: input_create.name,
      password_hash: input_create.password_hash
    }

    with %{valid?: true} = changeset <- User.changeset(params),
         {:ok, user} <- create_user_and_account(changeset) do
      {:ok, user}
    else
      {:error, changeset} ->
        msg_error = Changesets.render_errors(changeset)
        {:error, %{msg_error: msg_error}}

      %{valid?: false} = changeset ->
        msg_error = Changesets.render_errors(changeset)
        {:error, %{msg_error: msg_error}}
    end
  end

  defp create_user_and_account(user_changeset) do
    Multi.new()
    |> Multi.insert(:create_user, user_changeset)
    |> Multi.run(:create_account, fn _repo, %{create_user: user} ->
      insert_account(user)
    end)
    |> Multi.run(:preload_data, fn _repo, %{create_user: user, create_account: acc} ->
      preload_data(user, acc)
    end)
    |> run_transaction()
  end

  defp insert_account(user) do
    code = generate_code()

    %{user_id: user.id, account_code: code, balance: 100_000}
    |> Account.changeset()
    |> Repo.insert()
  end

  defp preload_data(user, acc) do
    {:ok, Map.put(user, :account, acc)}
  end

  defp run_transaction(multi) do
    case Repo.transaction(multi) do
      {:error, _operation, reason, _changes} -> {:error, reason}
      {:ok, %{preload_data: user}} -> {:ok, user}
    end
  end

  defp generate_code() do
    100_000..999_999
    |> Enum.random()
    |> to_string()
  end
end
