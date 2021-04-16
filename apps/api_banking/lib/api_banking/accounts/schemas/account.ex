defmodule ApiBanking.Accounts.Schemas.Account do
  use Ecto.Schema

  alias ApiBanking.Users.Schemas.User
  alias ApiBanking.Transactions.Schemas.Transaction
  import Ecto.Changeset

  @derive {Jason.Encoder, except: [:__meta__, :transactions, :user]}

  @required [:account_code, :balance, :user_id]

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
    |> validate_number(:balance,
      greater_than_or_equal_to: 0,
      message:
        "Balance unavailable to peform this operation. The account balance must be greater than 0."
    )
  end
end
