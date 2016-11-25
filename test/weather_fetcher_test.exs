defmodule WeatherFetcherTest do
  use ExUnit.Case # bring in the test functionality
  import ExUnit.CaptureIO # And allow us to capture stuff sent to stdout
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias Weatherbot.WeatherFetcher, as: WF

  test "its alive!" do
    use_cassette "weather_fetch" do
      assert WF.parsed_forecast() != "some invalid string"
    end
  end
end