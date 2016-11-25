defmodule WeatherFetcherTest do
  use ExUnit.Case # bring in the test functionality
  import ExUnit.CaptureIO # And allow us to capture stuff sent to stdout
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias Weatherbot.WeatherFetcher, as: WF

  test "fetches the weather" do
    use_cassette "weather_fetch" do
      expected = "Area forecast discussion \nNational Weather Service "
      fetched = WF.get_forecast |> WF.parsed_forecast |> String.slice(0..50)

      assert fetched == expected
    end
  end

  test "organizes into sections" do
    use_cassette "weather_fetch" do
      m = WF.get_section_map
      assert Map.fetch(m, "Updates") != nil
      assert Map.fetch(m, "Short term") != nil
      assert Map.fetch(m, "Long term") != nil
      assert Map.fetch(m, "Some missing section") == :error
    end
  end
end