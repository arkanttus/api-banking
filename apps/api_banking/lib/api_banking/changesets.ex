defmodule ApiBanking.Changesets do
  import Ecto.Changeset

  @email_regex ~r/^[A-Za-z0-9\._%+\-+']+@[A-Za-z0-9\.\-]+\.[A-Za-z]{2,4}$/

  def validate_email(changeset, field) do
    validate_format(changeset, field, @email_regex)
  end

  def validate_equals_fields(%{valid?: false} = changeset, _, _), do: changeset

  def validate_equals_fields(changeset, field, field_confirmation) do
    if field == field_confirmation do
      changeset
    else
      add_error(
        changeset,
        :email_and_confirmation,
        "Email and email confirmation must be the same"
      )
    end
  end
end
