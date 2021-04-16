defmodule ApiBankingWeb.Router do
  use ApiBankingWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ApiBankingWeb do
    pipe_through :api

    post "/users", UserController, :create
    post "/withdraw", TransactionController, :create_withdraw
    post "/transfer", TransactionController, :create_transfer
  end
end
