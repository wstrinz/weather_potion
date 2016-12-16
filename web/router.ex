defmodule Weatherbot.Router do
  use Weatherbot.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Weatherbot do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index

    post "/add_zip", WeatherController, :index
  end

  scope "/", Weatherbot do
    pipe_through :api

    post "/webhook", WeatherController, :receive_webhook
  end

  # Other scopes may use custom stacks.
  # scope "/api", Weatherbot do
  #   pipe_through :api
  # end
end
