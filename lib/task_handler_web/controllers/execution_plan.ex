defmodule TaskHandlerWeb.ExecutionPlanController do
  use TaskHandlerWeb, :controller
  alias TaskHandler.ExecutionPlanService
  alias TaskHandler.Schemas.Task
  alias TaskManager.ExecutionPlanMapper

  def create(conn, params) do
    with {:ok, %{tasks: tasks}} <- Tarams.cast(params, Task.api_in_schema()),
         {:ok, execution_plan} <- ExecutionPlanService.call(tasks) do
      response_to_content_type(conn, execution_plan)
    else
      {:error, errors} ->
        handle_errors(conn, errors)
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
        |> json(ExecutionPlanMapper.to_external(execution_plan))
    end
  end

  defp handle_errors(conn, {:circular_dependencies_error, message}) do
    conn
    |> put_status(422)
    |> json(%{error: message})
  end

  defp handle_errors(conn, errors) do
    conn
    |> put_status(400)
    |> json(%{error: errors})
  end
end
