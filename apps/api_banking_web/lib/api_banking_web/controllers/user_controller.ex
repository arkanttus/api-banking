defmodule ApiBankingWeb.UserController do
  use ApiBankingWeb, :controller
  alias ApiBanking.Users.Inputs
  alias ApiBanking.InputValidation

  def create(conn, params) do
    with {:ok, input_params} <- InputValidation.cast_and_apply(params, Inputs.Create),
         {:ok, user} <- ApiBanking.create_user(input_params) do
      user
      |> format_user()
      |> send_json(conn, 200)
    else
      {:error, %{msg_error: msg_error}} ->
        %{type: "bad_request", description: "invalid_input", details: msg_error}
        |> send_json(conn, 400)

      {:error, :email_conflict} ->
        %{type: "conflict", description: "Email already exists"}
        |> send_json(conn, 400)
    end
  end

  def format_user(user) do
    acc = user.account

    %{
      id: user.id,
      name: user.name,
      email: user.email,
      account: %{id: acc.id, account_code: acc.account_code, balance: acc.balance}
    }
  end

  def send_json(data, conn, status) do
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(status, Jason.encode!(data))
  end
end
