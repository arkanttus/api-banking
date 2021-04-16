defmodule ApiBanking.Users.Inputs.Create do
  use Ecto.Schema

  import Ecto.Changeset
  import ApiBanking.Changesets

  @required [:name, :email, :email_confirmation, :password]

  @primary_key false
  embedded_schema do
    field(:name, :string)
    field(:email, :string)
    field(:email_confirmation, :string)
    field(:password, :string)
    field(:password_hash, :string)
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @required)
    |> validate_required(@required)
    |> validate_length(:name, min: 3)
    |> validate_length(:password, min: 5)
    |> validate_confirmation(:email)
    |> validate_email(:email)
    |> validate_email(:email_confirmation)
    |> put_password()
  end
end
