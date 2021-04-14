defmodule ApiBanking.Accounts.Schemas.Account do
  use Ecto.Schema

  alias ApiBanking.Users.Schemas.User
  alias ApiBanking.Transactions.Schemas.Transaction
  import Ecto.Changeset

  @required [:account_code, :balance]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts" do
    field :account_code, :string
    field :balance, :integer

    belongs_to :user, User
    has_many :transactions, Transaction

    timestamps()
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @required)
    |> validate_required(@required)
    |> validate_number(:balance, greater_than_or_equal_to: 0)
  end
end
