defmodule WeatherFetcherTest do
  use ExUnit.Case # bring in the test functionality
  import ExUnit.CaptureIO # And allow us to capture stuff sent to stdout
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias Weatherbot.WeatherFetcher, as: WF

  test "fetches the weather" do
    use_cassette "weather_fetch" do
      expected = "\n000\nFXUS63 KMKX 110212 AAA\nAFDMKX\n\nArea Forecast D"
      fetched = WF.get_forecast |> WF.parsed_forecast |> String.slice(0..50)

      assert fetched == expected
    end
  end

  test "organizes into sections" do
    use_cassette "weather_fetch" do
      m = WF.get_forecast |> WF.forecast_sections |> WF.remove_ignored_sections(["MARINE"])
      assert String.contains?(Enum.at(m, 0), "UPDATE") == true
      # IO.inspect(m)
      # assert String.contains?(Enum.at(m, 1), "Short term") == true
      # assert String.contains?(Enum.at(m, 1), "Long term") == true
      assert String.contains?(Enum.at(m, 1), "Some missing section") == false
    end
  end

  # test "remove_other_sections" do
  #   teststr = "weather is happening \nLong term... probs more weather"
  #   expected = "*Short term...* weather is happening \n"
  #   pattern = "Short term..."
  #   assert WF.remove_other_sections(teststr, pattern) == expected
  # end
end
