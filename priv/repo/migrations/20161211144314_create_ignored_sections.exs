defmodule Weatherbot.Repo.Migrations.CreateIgnoredSections do
  use Ecto.Migration

  def change do
    create table(:ignored_sections) do
      add :value, :string, null: false
      add :station_id, references(:stations)

      timestamps
    end

    create index(:ignored_sections, [:station_id])
  end
end
