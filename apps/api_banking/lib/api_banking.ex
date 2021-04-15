defmodule ApiBanking do
  alias ApiBanking.Users.Create, as: UserCreate

  defdelegate create_user(params), to: UserCreate, as: :create_user
end
