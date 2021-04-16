defmodule ApiBanking do
  alias ApiBanking.Users.Create, as: UserCreate
  alias ApiBanking.Transactions.CreateWithdraw

  defdelegate create_user(params), to: UserCreate, as: :create_user

  defdelegate create_withdraw(params), to: CreateWithdraw, as: :create_withdraw
end
