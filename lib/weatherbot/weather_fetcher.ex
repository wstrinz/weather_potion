defmodule Weatherbot.WeatherFetcher do
  @url_base "https://www.wunderground.com/DisplayDisc.asp?DiscussionCode="
  @mn_url "https://www.wunderground.com/DisplayDisc.asp?DiscussionCode=MPX"
  @madison_url "http://forecast.weather.gov/product.php?site=CRH&product=AFD&issuedby=MKX"
  @section_headers ["Update...", "Short term...", "Long term..."]
  @update_regex Enum.at(@section_headers, 0)
  @short_term_reg Enum.at(@section_headers, 1)
  @long_term_reg Enum.at(@section_headers, 2)

  def url_for_site(site_code) do
    "#{@url_base}#{site_code}"
  end

  def get_forecast(site_code) do
    HTTPoison.get!(url_for_site(site_code)).body
  end

  def get_forecast do
    get_forecast("MPX")
  end

  def parsed_forecast(forecast_body) do
    forecast_body
    |> Floki.parse
    |> Floki.find(".inner-content pre")
    |> Floki.text
  end

  def forecast_sections(forecast_body) do
    parsed_forecast(forecast_body)
    |> String.split("&&")
    |> Enum.map(&String.strip/1)
  end

  def remove_other_sections(section, reg) do
    other_regexes = @section_headers |> Enum.reject(fn r -> r == reg end)

    Enum.reduce(other_regexes, "#{reg}#{section}", fn r, str ->
      String.split(str, r)
      |> Enum.at(0)
    end)
  end

  def section_for(reg, sections) do
    section =
      sections
      |> Enum.find(fn sect -> String.contains?(sect, reg) end)

    if section do
      section
      |> String.split(reg)
      |> Enum.at(-1)
      |> String.strip
      |> remove_other_sections(reg)
    else
      nil
    end
  end

  def section_map(sections) do
    sections = sections
    %{
      "Updates" => section_for(@update_regex, sections),
      "Short term" => section_for(@short_term_reg, sections),
      "Long term" => section_for(@long_term_reg, sections)
    }
  end

  def chunks_for(msg) do
    if String.length(msg) >= 2000 do
      msg
      |> String.graphemes
      |> Enum.chunk(2000)
      |> Enum.map(&Enum.join/1)
    else
      msg
    end
  end

  def sendmsg(sections) do
    sections
    |> Enum.filter(fn {_, v} -> v end)
    |> Enum.map(fn {k, v} -> chunks_for "*#{k}* #{v}" end)
    |> List.flatten
    |> Enum.map(&(String.replace &1, ~r/\n(\w)/, " \\1"))
    |> Enum.map(&SlackWebhook.send/1)
    |> IO.inspect
  end


  def get_section_map do
    get_forecast
    |> forecast_sections
    |> section_map
  end

  def run do
    get_section_map |> sendmsg
  end
end