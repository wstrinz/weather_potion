defmodule Weatherbot.Repo.Migrations.AddLastForecastToStations do
  use Ecto.Migration

  def change do
    alter table(:stations) do
      add :last_forecast, :text
    end
  end
end
