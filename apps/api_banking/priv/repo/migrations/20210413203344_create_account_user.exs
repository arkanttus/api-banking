defmodule ApiBanking.Repo.Migrations.CreateAccountUser do
  use Ecto.Migration

  def change do
    create table(:account_user, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :balance, :float

      add :user_id, references(:users, type: :uuid)

      timestamps()
    end
  end
end
