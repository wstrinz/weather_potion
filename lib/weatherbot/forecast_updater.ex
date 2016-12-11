defmodule Weatherbot.ForecastUpdater do
  import Ecto.Query, only: [from: 2]
  alias Weatherbot.{Repo, Station, IgnoredSection}
  alias Weatherbot.WeatherFetcher, as: Fetcher

  def ignored_strings_for(station) do
    (from ig in IgnoredSection,
      where: ig.station_id == ^station.id,
      select: ig.value)
    |> Repo.all
  end

  def latest_forecast(station) do
    Fetcher.get_section_list(station.code, ignored_strings_for(station)) |> Enum.join("\n&&\n")
  end

  def update_station(station) do
    latest_forecast(station)
    |> (fn fc -> Station.changeset(station, %{last_forecast: fc}) end).()
    |> Repo.update!
  end

  def run do
    stations = Repo.all(Station)
    Enum.map(stations, fn s -> update_station(s) end)
  end
end
