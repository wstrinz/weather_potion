defmodule Weatherbot.WeatherController do
  use Weatherbot.Web, :controller

  def receive_webhook(conn, params) do
    msg_text = Map.get(params, "text")
    spawn fn -> Weatherbot.SlackInterface.handle_received_message(msg_text) end
    json conn, %{text: "Thanks for the message!"}
  end
end
