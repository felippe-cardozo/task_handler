defmodule TaskHandlerWeb.Router do
  use TaskHandlerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", TaskHandlerWeb do
    pipe_through :api
  end
end
