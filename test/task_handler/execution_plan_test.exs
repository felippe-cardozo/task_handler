defmodule TaskHandler.ExecutionPlanTest do
  use ExUnit.Case, async: true
  alias TaskHandler.ExecutionPlan

  describe "build/1" do
    test "when there are no dependencies it returns the initial list" do
      task_a = task("task_a")
      task_b = task("task_b")
      task_c = task("task_c")

      assert [^task_c, ^task_b, ^task_a] = ExecutionPlan.build([task_c, task_b, task_a])
    end

    test "tasks who have dependencies are placed after their dependencies" do
      task_a = task("task_a")
      task_b = task("task_b", ["task_a"])
      task_c = task("task_c", ["task_a", "task_b"])

      assert [^task_a, ^task_b, ^task_c] = ExecutionPlan.build([task_c, task_b, task_a])
    end

    test "when there are circular dependencies it raises an error" do
      task_a = task("task_a")
      task_b = task("task_b", ["task_a", "task_c"])
      task_c = task("task_c", ["task_a", "task_b"])

      assert_raise(TaskHandler.Errors.CircularDependenciesError, fn ->
        ExecutionPlan.build([task_a, task_b, task_c])
      end)
    end
  end

  defp task(name, dependencies) do
    %{"name" => name, "command" => "echo #{name}", "requires" => dependencies}
  end

  defp task(name) do
    %{"name" => name, "command" => "echo #{name}"}
  end
end
