defmodule ApiBanking.Repo.Migrations.CreateTransaction do
  use Ecto.Migration

  def change do
    create table(:transaction, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :value, :float

      add :user_origin_id, references(:users, type: :uuid)
      add :user_target_id, references(:users, type: :uuid)

      timestamps()
    end
  end
end
