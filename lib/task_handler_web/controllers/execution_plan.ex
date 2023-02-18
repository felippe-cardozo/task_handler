defmodule TaskHandlerWeb.ExecutionPlanController do
  use TaskHandlerWeb, :controller
  alias TaskHandler.ExecutionPlan
  alias TaskHandler.Schemas.Task
  alias TaskManager.ExecutionPlanMapper

  def create(conn, %{"tasks" => tasks} = params) do
    try do
      with {:ok, _} <- Tarams.cast(params, Task.api_schema()),
           execution_plan <- ExecutionPlan.build(tasks) do
        response_to_content_type(conn, execution_plan)
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

  defp response_to_content_type(conn, execution_plan) do
    case get_req_header(conn, "accept") do
      ["application/x-sh"] ->
        conn
        |> put_resp_content_type("application/x-sh")
        |> put_status(201)
        |> text(ExecutionPlanMapper.to_shell_script(execution_plan))

      _ ->
        conn
        |> put_status(201)
        |> json(execution_plan)
    end
  end
end
