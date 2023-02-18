defmodule TaskManager.ExecutionPlanMapper do
  alias TaskHandler.Schemas

  def to_shell_script(execution_plan) do
    shell_headers = "#!/usr/bin/env sh\n"

    commands =
      execution_plan
      |> Enum.map(fn task -> task.command end)
      |> Enum.join(";")

    shell_headers <> commands
  end

  def to_external(execution_plan) do
    Enum.map(execution_plan, &to_external_task/1)
  end

  defp to_external_task(task) do
    {:ok, external_task} = Tarams.cast(task, Schemas.Task.out_schema())
    external_task
  end
end
