defmodule ApiBanking.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :amount, :integer
      add :description, :string, null: true
      add :status, :string

      add :account_origin_id, references(:accounts, type: :uuid)
      add :account_target_id, references(:accounts, type: :uuid)

      timestamps()
    end
  end
end
