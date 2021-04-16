defmodule ApiBanking.Users.Schemas.User do
  use Ecto.Schema

  import Ecto.Changeset
  import ApiBanking.Changesets
  alias ApiBanking.Accounts.Schemas.Account

  @derive {Jason.Encoder, except: [:__meta__, :account]}

  @required [:name, :email, :password_hash]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field(:name, :string)
    field(:email, :string)
    field(:password_hash, :string)

    has_one(:account, Account)

    timestamps()
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @required)
    |> validate_required(@required)
    |> validate_length(:name, min: 3)
    |> validate_email(:email)
    |> unique_constraint([:email])
  end
end
