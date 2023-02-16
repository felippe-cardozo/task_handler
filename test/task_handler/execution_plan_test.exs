defmodule TaskHandler.ExecutionPlanTest do
  use ExUnit.Case, async: true
  alias TaskHandler.ExecutionPlan
  alias Support.Task

  describe "build/1" do
    test "when there are no dependencies it returns the initial list" do
      task_a = Task.build("task_a")
      task_b = Task.build("task_b")
      task_c = Task.build("task_c")

      assert [^task_c, ^task_b, ^task_a] = ExecutionPlan.build([task_c, task_b, task_a])
    end

    test "tasks who have dependencies are placed after their dependencies" do
      task_a = Task.build("task_a")
      task_b = Task.build("task_b", ["task_a"])
      task_c = Task.build("task_c", ["task_a", "task_b"])

      assert [^task_a, ^task_b, ^task_c] = ExecutionPlan.build([task_c, task_b, task_a])
    end

    test "when there are circular dependencies it raises an error" do
      task_a = Task.build("task_a")
      task_b = Task.build("task_b", ["task_a", "task_c"])
      task_c = Task.build("task_c", ["task_a", "task_b"])

      assert_raise(TaskHandler.Errors.CircularDependenciesError, fn ->
        ExecutionPlan.build([task_a, task_b, task_c])
      end)
    end
  end
end
