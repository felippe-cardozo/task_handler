defmodule TaskHandler.ExecutionPlanService do
  alias TaskHandler.ExecutionPlan

  def call(tasks) do
    try do
      {:ok, ExecutionPlan.build(tasks)}
    rescue
      e in TaskHandler.Errors.CircularDependenciesError ->
        {:error, {:circular_dependencies_error, e.message}}

      e ->
        reraise e, __STACKTRACE__
    end
  end
end
