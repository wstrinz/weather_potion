defmodule Weatherbot.WeatherFetcher do
  @url "https://www.wunderground.com/DisplayDisc.asp?DiscussionCode=MPX"
  @otherurl "http://forecast.weather.gov/product.php?site=CRH&product=AFD&issuedby=MKX"
  @update_regex ~r/Update\.\.\./
  @short_term_reg ~r/Short term\.\.\./
  @long_term_reg ~r/Long term\.\.\./

  def hello do
    f = forecast()
    IO.inspect f
  end

  def forecast do
    forecast = HTTPoison.get!(@url)
    forecast.body
  end

  def parsed_forecast do
     finder = &(Floki.find(&1, ".inner-content pre"))
     forecast()
     |> Floki.parse
     |> finder.()
     |> Floki.text
  end

  def forecast_sections do
    stripped = &(String.strip(&1))
    parsed_forecast
    |> String.split("&&")
    |> Enum.map(stripped)
  end

  def section_for(reg, sections) do
    update_section =
      sections
      |> Enum.find(fn sect -> Regex.match?(reg, sect)  end)

    if update_section do
      update_section
      |> String.split(reg)
      |> Enum.at(-1)
      |> String.strip
    else
      nil
    end
  end

  def section_map do
    sections = forecast_sections
    %{
      "Updates" => section_for(@update_regex, sections),
      "Short term" => section_for(@short_term_reg, sections),
      "Long term" => section_for(@long_term_reg, sections)
    }
  end

  def chunks_for(msg) do
    if String.length(msg) >= 2000 do
      msg |>
      String.graphemes |>
      Enum.chunk(2000) |>
      Enum.map(&(Enum.join(&1)))
    else
      msg
    end
  end

  def sendmsg do
    section_map |>
    Enum.map(fn {k, v} -> chunks_for "*#{k}* #{v}" end)
    |> List.flatten
    |> Enum.map(&(String.replace(&1, ~r/\n(\w)/, " \\1")))
    |> Enum.map(&(SlackWebhook.send(&1)))
    |> IO.inspect
  end
end