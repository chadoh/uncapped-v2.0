defmodule Uncapped.Router do
  use Uncapped.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Uncapped.Auth, repo: Uncapped.Repo
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Uncapped do
    pipe_through :browser # Use the default browser stack

    resources "/users", UserController, only: [:index, :show, :new, :create]
    resources "/sessions", SessionController, only: [:new, :create, :delete]

    get "/", PageController, :index
  end

  scope "/manage", Uncapped do
    pipe_through [:browser, :authenticate_user]

    resources "/breweries", BreweryController, only: [:index, :show, :new, :create, :delete] do
      post "/addbeer", BreweryController, :add_beer
    end

    resources "/beer", BeerController, only: [:show, :index] do
      post "/checkin", BeerController, :checkin
    end
    resources "/checkin", CheckinController, only: [:show, :index]
  end
end
