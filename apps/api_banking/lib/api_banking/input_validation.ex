defmodule ApiBanking.InputValidation do
  alias ApiBanking.Changesets

  @moduledoc """
  Validate a map params with a given module schema.
  """

  @doc """
  Receive a params and a module and call the changeset function of the module pass the params.
  If success returns the module schema, otherwise returns the ecto changeset schema.
  """
  @spec cast_and_apply(map(), module()) :: {:ok, struct()} | {:error, Ecto.Changeset.t()}
  def cast_and_apply(params, module) do
    case module.changeset(params) do
      %{valid?: true} = changeset ->
        {:ok, Ecto.Changeset.apply_changes(changeset)}

      %{valid?: false} = changeset ->
        msg_error = Changesets.render_errors(changeset)

        {:error, %{msg_error: msg_error}}
    end
  end
end
