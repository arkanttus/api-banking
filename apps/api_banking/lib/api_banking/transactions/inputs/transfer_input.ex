defmodule ApiBanking.Transactions.Inputs.Transfer do
  use Ecto.Schema
  import Ecto.Changeset

  @required [:amount, :description, :account_origin_code, :account_target_code]

  @primary_key false
  embedded_schema do
    field(:amount, :integer)
    field(:description, :string)
    field(:account_origin_code, :string)
    field(:account_target_code, :string)
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @required)
    |> validate_required(@required)
    |> validate_number(:amount, greater_than_or_equal_to: 1)
  end
end
