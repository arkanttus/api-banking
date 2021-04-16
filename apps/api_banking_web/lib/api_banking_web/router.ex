defmodule ApiBankingWeb.Router do
  use ApiBankingWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ApiBankingWeb do
    pipe_through :api

    post "/users", UserController, :create
  end
end
