defmodule TaskHandlerWeb.Router do
  use TaskHandlerWeb, :router

  pipeline :api do
    plug :accepts, ["json", "sh"]
  end

  scope "/api", TaskHandlerWeb do
    pipe_through :api
    post "/execution_plans", ExecutionPlanController, :create
  end
end
