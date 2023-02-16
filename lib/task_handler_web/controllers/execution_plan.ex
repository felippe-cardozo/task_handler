defmodule TaskHandlerWeb.ExecutionPlanController do
  use TaskHandlerWeb, :controller
  alias TaskHandler.ExecutionPlan
  alias TaskHandler.Schemas.Task

  def create(conn, %{"tasks" => tasks} = params) do
    try do
      with {:ok, _} <- Tarams.cast(params, Task.api_schema()),
           execution_plan <- ExecutionPlan.build(tasks) do
        conn
        |> put_status(201)
        |> json(execution_plan)
      else
        {:error, errors} ->
          conn
          |> put_status(400)
          |> json(%{error: errors})
      end
    rescue
      e in TaskHandler.Errors.CircularDependenciesError ->
        conn
        |> put_status(422)
        |> json(%{error: e.message})

      e ->
        reraise e, __STACKTRACE__
    end
  end
end
