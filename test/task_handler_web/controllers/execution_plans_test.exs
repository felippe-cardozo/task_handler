defmodule TaskManagerWeb.Controllers.ExecutionPlans do
  use TaskHandlerWeb.ConnCase, async: true
  alias Support.Task

  describe "POST /api/execution_plans with accept application/json" do
    setup %{conn: conn} do
      {:ok,
       conn:
         conn
         |> put_req_header("accept", "application/json")
         |> put_req_header("content-type", "application/json")}
    end

    test "returns 422 when there are circular dependencies", %{conn: conn} do
      task_a = Task.build("task_a")
      task_b = Task.build("task_b", ["task_a", "task_c"])
      task_c = Task.build("task_c", ["task_a", "task_b"])

      conn = post(conn, "/api/execution_plans", tasks: [task_a, task_b, task_c])

      assert json_response(conn, 422) == %{
               "error" => "circular dependencies were found among the tasks"
             }
    end

    test "returns 202 and the execution_plan for the tasks", %{conn: conn} do
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

  describe "POST /api/execution_plans with accept application/x-sh" do
    setup %{conn: conn} do
      {:ok,
       conn:
         conn
         |> put_req_header("accept", "application/x-sh")
         |> put_req_header("content-type", "application/json")}
    end

    test "returns 201 and a bash script to execute the tasks", %{conn: conn} do
      task_a = Task.build("task_a")
      task_b = Task.build("task_b", ["task_a"])
      task_c = Task.build("task_c", ["task_a", "task_b"])

      conn = post(conn, "/api/execution_plans", tasks: [task_c, task_b, task_a])

      assert conn.status == 201

      assert conn.resp_body == "#!/usr/bin/env sh\necho task_a;echo task_b;echo task_c"
    end
  end
end
