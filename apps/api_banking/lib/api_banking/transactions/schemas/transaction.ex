defmodule ApiBanking.Transactions.Schemas.Transaction do
  use Ecto.Schema

  alias ApiBanking.Accounts.Schemas.Account
  import Ecto.Changeset

  @required [:account_origin, :amount, :description, :account_target, :status]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "transactions" do
    field :amount, :integer
    field :description, :string
    field :status, :string

    belongs_to :account_origin, Account
    belongs_to :account_target, Account

    timestamps()
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @required)
    |> validate_required(@required)
  end
end
