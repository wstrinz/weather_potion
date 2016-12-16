defmodule Weatherbot.SlackCommandHandler do
  @command_list ~w[add delete ignore_string get_forecast metadata help clear]

  alias Weatherbot.{Repo, Station, IgnoredSection, ForecastUpdater}

  def handle_command("add", [code | title]) do
    chg = Station.changeset(%Station{}, %{code: code, title: Enum.join(title, " ")})
    res = Repo.insert(chg)
    case res do
      {:ok, result} -> "Added #{title} (#{code})"
      {:error, result} ->
        "Error adding station"
    end
  end

  def handle_command("delete", [code | rest]) do
    current = Station.for_code(code)
    if current do
      res = Repo.delete(current)
      case res do
        {:ok, result} -> "Deleted #{current.title} (#{code})"
        {:error, result} ->
          "Error deleting station"
        end
    else
      "No Station for #{code}"
    end
  end

  def handle_command("clear", [code | rest]) do
    current = Station.for_code(code)
    if current do
      res = Station.changeset(current, %{last_forecast: ""})
      |> Repo.update
      case res do
        {:ok, result} -> "Cleared stored forecast for #{current.title} (#{current.code})"
        {:error, result} ->
          "Error clearing stored forecast"
        end
    else
      "No Station for #{code}"
    end
  end

  def handle_command("clear_ignore_strings", [code | rest]) do
    current = Station.for_code(code)
    if current do
      res = Station.changeset(current, %{last_forecast: ""})
      |> Repo.update
      case res do
        {:ok, result} -> "Cleared stored forecast for #{current.title} (#{current.code})"
        {:error, result} ->
          "Error clearing stored forecast"
        end
    else
      "No Station for #{code}"
    end
  end

  def handle_command("ignore_string", [code | rest]) do
    current = Station.for_code(code)
    to_ignore = Enum.join(rest, " ")
    if current do
      res = IgnoredSection.changeset(%IgnoredSection{}, %{station_id: current.id, value: to_ignore})
      |> Repo.insert

      case res do
        {:ok, result} -> "Added '#{to_ignore}' to ignore list #{current.code}"
        {:error, result} ->
          "Error adding ignore string"
        end
    else
      "No Station for #{code}"
    end
  end

  def handle_command("get_forecast", rest) do
    ForecastUpdater.run
    Enum.at(Weatherbot.SlackInterface.latest_updates, 0)
  end

  def handle_command("help", rest) do
    ~s"""
    Weatherbot understands:\n\n
    add a new station: `add <station_code> <title>`\n
    delete station: `delete <station_code>`\n
    clear current forecast: `clear <station_code>`\n
    add an ignore string: `ignore_string <station_code> <string_to_ignore>`\n
    clear ignore strings: `clear_ignore_string <station_code>`\n
    fetch and send new updates: `get_forecast`\n
    get configuration: `metadata`\n
    this help text: `help`\n
    """
  end

  def handle_command(unknown, rest) do
    "you put in an unknown command (#{unknown}), so you get the help text \n#{handle_command("help", rest)}"
  end

  def parse_message(msg) do
    pieces = msg
    |> String.split(" ")
    |> Enum.slice(1..-1)

    [ cmd | rest ] = pieces

    handle_command(cmd, rest)
  end
end
