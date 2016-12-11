defmodule Weatherbot.Repo.Migrations.CreateStations do
  use Ecto.Migration

  def change do
    create table(:stations) do
      add :title, :string, unique: true, null: false
      add :code, :string, unique: true, null: false

      timestamps
    end

    create unique_index(:stations, [:code], name: :station_codes)
  end
end
