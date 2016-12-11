defmodule Weatherbot.SlackInterface do
  def chunks_for(msg) do
    if String.length(msg) >= 2000 do
      msg
      |> String.graphemes
      |> Enum.chunk(2000)
      |> Enum.map(&Enum.join/1)
    else
      [msg]
    end
  end

  def send_sections(sections) do
    sections
    |> Enum.filter(fn {_, v} -> v end)
    |> Map.values
    |> Enum.join("\n\n")
    |> sendmsg
  end

  def sendmsg(msg) do
    msg
    |> chunks_for
    |> List.flatten
    |> Enum.map(&(String.replace &1, ~r/\n(\w)/, " \\1"))
    |> Enum.map(&SlackWebhook.send/1)
    |> IO.inspect
  end

  def format_station_messages(station) do
    Enum.concat(["*Forecast for #{station.title}*:"],
                String.split(station.last_forecast, "&&"))
  end

  def send_latest_updates do
    stations = Weatherbot.Repo.all(Weatherbot.Station)
    Enum.map stations, fn station ->
      format_station_messages(station) |> Enum.map(&sendmsg/1)
    end
  end
end
