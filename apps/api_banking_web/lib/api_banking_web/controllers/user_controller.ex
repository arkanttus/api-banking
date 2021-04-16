defmodule ApiBankingWeb.UserController do
  use ApiBankingWeb, :controller
  alias ApiBanking.Users.Inputs
  alias ApiBanking.InputValidation

  def create(conn, params) do
    with {:ok, input_changeset} <- InputValidation.cast_and_apply(params, Inputs.Create),
         {:ok, user} <- ApiBanking.create_user(input_changeset) do
      send_json(conn, 200, user)
    else
      {:error, %{msg_error: msg_error}} ->
        msg = %{type: "bad_request", description: "invalid_input", details: msg_error}
        send_json(conn, 400, msg)

      {:error, :email_conflict} ->
        msg = %{type: "conflict", description: "Email already exists"}
        send_json(conn, 400, msg)
    end
  end

  def send_json(conn, status, data) do
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(status, Jason.encode!(data))
  end
end
