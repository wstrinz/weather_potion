defmodule Weatherbot.Station do
  use Ecto.Schema
  import Ecto.Changeset

  schema "stations" do
    field :title, :string
    field :code, :string
    field :last_forecast, :string

    timestamps
  end

  @required_fields ~w{title code}
  @optional_fields ~w{last_forecast}

  def changeset(station, params \\ :empty) do
    station
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:station_codes)
  end
end
