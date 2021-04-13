defmodule ApiBanking.Users.Inputs.Create do
  use Ecto.Schema

  import Ecto.Changeset
  import ApiBanking.Changesets

  @required [:name, :email, :email_confirmation, :password]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :name, :string
    field :email, :string
    field :email_confirmation, :string
    field :password, :string
    field :password_hash, :string

    timestamps()
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @required)
    |> validate_required(@required)
    |> validate_length(:name, min: 3)
    |> validate_email(:email)
    |> validate_email(:email_confirmation)
    |> validate_equals_fields(:email, :email_confirmation)
  end
end
