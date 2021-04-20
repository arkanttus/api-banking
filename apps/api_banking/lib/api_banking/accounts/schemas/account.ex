defmodule ApiBanking.Accounts.Schemas.Account do
  use Ecto.Schema

  alias ApiBanking.Transactions.Schemas.Transaction
  alias ApiBanking.Users.Schemas.User
  import Ecto.Changeset

  @derive {Jason.Encoder, except: [:__meta__]}

  @required [:account_code, :balance, :user_id]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts" do
    field(:account_code, :string)
    field(:balance, :integer)

    belongs_to(:user, User)
    has_many(:transactions_out, Transaction, foreign_key: :account_origin_id)
    has_many(:transactions_in, Transaction, foreign_key: :account_target_id)

    timestamps()
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @required)
    |> validate_required(@required)
    |> validate_number(:balance,
      greater_than_or_equal_to: 0,
      message:
        "Balance unavailable to peform this operation. The account balance cannot be negative."
    )
  end
end
