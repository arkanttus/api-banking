defmodule ApiBanking.Users.Create do
  alias ApiBanking.Repo
  alias Ecto.Multi
  alias ApiBanking.Users.Schemas.User
  alias ApiBanking.Accounts.Schemas.Account

  require Logger

  def create_user(struct) when is_struct(struct) do
    params = %{email: struct.email, name: struct.name, password_hash: struct.password_hash}
    create_user(params)
  end

  def create_user(params) do
    Logger.info("Inserting new User")

    with %{valid?: true} = changeset <- User.changeset(params),
         {:ok, user} <- create_user_and_account(changeset) do
      {:ok, user}
    else
      %{valid?: false} = changeset ->
        msg_error =
          Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
            Enum.reduce(opts, msg, fn {key, value}, acc ->
              String.replace(acc, "%{#{key}}", to_string(value))
            end)
          end)

        {:error, %{msg_error: msg_error}}
    end
  rescue
    Ecto.ConstraintError ->
      Logger.error("Email already in use")

      {:error, :email_conflict}
  end

  defp create_user_and_account(user_changeset) do
    Multi.new()
    |> Multi.insert(:create_user, user_changeset)
    |> Multi.run(:create_account, fn repo, %{create_user: user} ->
      insert_account(repo, user)
    end)
    |> Multi.run(:preload_data, fn repo, %{create_user: user} ->
      preload_data(repo, user)
    end)
    |> run_transaction()
  end

  defp insert_account(repo, user) do
    code = generate_code()

    Account.changeset(%{user_id: user.id, account_code: code, balance: 100_000})
    |> repo.insert()
  end

  defp preload_data(repo, user) do
    {:ok, repo.preload(user, :account)}
  end

  defp run_transaction(multi) do
    case Repo.transaction(multi) do
      {:error, _operation, reason, _changes} -> {:error, reason}
      {:ok, %{preload_data: user}} -> {:ok, user}
    end
  end

  defp generate_code() do
    Enum.reduce(0..5, "", fn _, acc ->
      num = Enum.random(0..9) |> to_string()
      acc <> num
    end)
  end
end
