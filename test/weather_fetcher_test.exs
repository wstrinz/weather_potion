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
      assert Map.get(m, "Updates") != nil
      assert Map.get(m, "Short term") != ""
      assert Map.get(m, "Long term") != ""
      assert Map.get(m, "Some missing section") == nil
    end
  end

  test "remove_other_sections" do
    teststr = "Short term... weather is happening \nLong term... probs more weather"
    expected = "Short term... weather is happening \n"
    pattern = "Short term..."
    assert WF.remove_other_sections(String.split(teststr, pattern), pattern) == expected
  end
end