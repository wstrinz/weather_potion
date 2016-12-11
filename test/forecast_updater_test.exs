defmodule ForecastUpdaterTest do
  use ExUnit.Case # bring in the test functionality
  import ExUnit.CaptureIO # And allow us to capture stuff sent to stdout
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias Weatherbot.ForecastUpdater, as: F
  alias Weatherbot.{Repo, Station}

  test "updates weather models" do
    use_cassette "forecast_update" do
      # assert Repo.all(Station) == "foo"
    end
  end
end
