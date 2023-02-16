defmodule TaskManagerWeb.Controllers.ExecutionPlans do
  use TaskHandlerWeb.ConnCase, async: true
  alias Support.Task

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
    {:ok, conn: put_req_header(conn, "content-type", "application/json")}
  end

  describe "POST /api/execution_plans" do
    test "returns 422 when there are circular dependencies", %{conn: conn} do
      task_a = Task.build("task_a")
      task_b = Task.build("task_b", ["task_a", "task_c"])
      task_c = Task.build("task_c", ["task_a", "task_b"])

      conn = post(conn, "/api/execution_plans", tasks: [task_a, task_b, task_c])

      assert json_response(conn, 422) == %{
               "error" => "circular dependencies were found among the tasks"
             }
    end

    test "returns 200 and the execution_plan for the tasks", %{conn: conn} do
      task_a = Task.build("task_a")
      task_b = Task.build("task_b", ["task_a"])
      task_c = Task.build("task_c", ["task_a", "task_b"])

      conn = post(conn, "/api/execution_plans", tasks: [task_c, task_b, task_a])

      assert json_response(conn, 201) ==
               [task_a, task_b, task_c]
    end

    test "returns 400 when the payload is not following the contract", %{conn: conn} do
      task_a = Task.build("task_a")
      task_b = Task.build("task_b", ["task_a"])
      task_without_a_name = %{"requires" => ["task_b"], "command" => "ls -a"}

      conn = post(conn, "/api/execution_plans", tasks: [task_a, task_b, task_without_a_name])

      assert json_response(conn, 400) == %{"error" => %{"tasks" => %{"name" => ["is required"]}}}
    end
  end
end
