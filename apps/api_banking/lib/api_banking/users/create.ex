defmodule ApiBanking.Users.Create do
  alias ApiBanking.Repo
  alias ApiBanking.Users.Schemas.User

  require Logger

  def create_user(struct) when is_struct(struct) do
    params = %{email: struct.email, name: struct.name, password_hash: struct.password_hash}
    create_user(params)
  end

  def create_user(params) do
    Logger.info("Inserting new User")

    with %{valid?: true} = changeset <- User.changeset(params),
         {:ok, user} <- Repo.insert(changeset) do
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
end
