defmodule TaskHandler.ExecutionPlan do
  alias TaskHandler.Errors.CircularDependenciesError

  def build(tasks) do
    Enum.reduce_while(
      tasks,
      %{execution: [], attempts: []},
      fn task, acc ->
        if execution_completed?(tasks, acc) do
          {:halt, acc}
        else
          {:cont, add_to_execution(task, tasks, acc)}
        end
      end
    )
    |> handle_results()
  end

  defp add_to_execution(%{"requires" => dependencies} = task, tasks, execution) do
    # add all dependencies
    execution_with_dependencies =
      Enum.reduce(
        dependencies,
        add_to_attempts(task, execution),
        fn dep_name, acc ->
          if circular_dependencies?(task, acc) do
            raise CircularDependenciesError
          else
            dep = find_task(tasks, dep_name)
            add_to_execution(dep, tasks, acc)
          end
        end
      )

    # add task now that depencies are resolved
    add(task, execution_with_dependencies)
  end

  # when task has no depencies
  defp add_to_execution(task, _tasks, execution), do: add(task, execution)

  defp add_to_attempts(task, %{attempts: attempts} = execution_attempts) do
    Map.put(execution_attempts, :attempts, [task | attempts])
  end

  defp add(task, %{execution: execution} = acc) do
    if Enum.member?(execution, task) do
      acc
    else
      Map.put(acc, :execution, execution ++ [task])
    end
  end

  defp find_task(tasks, name) do
    Enum.find(tasks, fn item -> item["name"] == name end)
  end

  defp execution_completed?(tasks, %{execution: execution}) do
    Enum.count(tasks) == Enum.count(execution)
  end

  defp circular_dependencies?(task, %{attempts: attempts, execution: execution}) do
    number_of_attempts(attempts, task) > 1 && !Enum.member?(execution, task)
  end

  defp number_of_attempts(attempts, task) do
    Enum.filter(attempts, fn item -> item == task end) |> Enum.count()
  end

  defp handle_results(%{execution: execution}), do: execution
  
end
