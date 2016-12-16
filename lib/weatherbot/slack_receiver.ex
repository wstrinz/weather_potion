defmodule Weatherbot.SlackReceiver do
  # def auth do
  #   headers = [{"Content-Type", "application/json"}]
  #   resp = HTTPoison.post!("https://slack.com/api/rtm.start", body, headers)
  #   resp
  # end

  def connect do
    {:ok, body} = Poison.encode %{token: Application.get_env(:weatherbot, :slackbot_token)}
    headers = [{"Content-Type", "application/json"}]
    resp = HTTPoison.post!("https://slack.com/api/rtm.start", body, headers)
    resp
  end
end
