defmodule Weatherbot.SlackInterface do
  alias Weatherbot.SlackCommandHandler, as: Cmd

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
    |> Enum.filter(fn x -> x end)
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
    |> Enum.join(" ")
  end

  def latest_updates do
    Weatherbot.Repo.all(Weatherbot.Station)
    |> Enum.map &format_station_messages/1
  end

  def send_latest_updates do
    latest_updates |> Enum.map(&sendmsg/1)
  end

  def handle_received_message(msg) do
    Cmd.parse_message(msg)
    |> sendmsg
  end
end
