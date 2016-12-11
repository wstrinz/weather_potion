defmodule Weatherbot.IgnoredSection do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ignored_sections" do
    field :value, :string
    field :station_id, :integer

    timestamps
  end

  @required_fields ~w{value station_id}
  @optional_fields ~w{}

  def changeset(section, params \\ :empty) do
    section
    |> cast(params, @required_fields, @optional_fields)
    |> foreign_key_constraint(:station_id)
  end
end
