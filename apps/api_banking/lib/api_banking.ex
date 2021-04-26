defmodule ApiBanking do
  alias ApiBanking.Users.Create, as: UserCreate
  alias ApiBanking.Transactions.CreateWithdraw
  alias ApiBanking.Transactions.CreateTransfer
  alias ApiBanking.Accounts.Statement

  defdelegate create_user(params), to: UserCreate, as: :create_user

  defdelegate create_withdraw(params), to: CreateWithdraw, as: :create_withdraw

  defdelegate create_transfer(params), to: CreateTransfer, as: :create_transfer

  defdelegate get_statement(acc_id), to: Statement, as: :get_statement
end
