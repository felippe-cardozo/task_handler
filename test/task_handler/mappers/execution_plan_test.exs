defmodule TaskManager.ExecutionPlanMapperTest do
  use ExUnit.Case, async: true
  alias TaskManager.ExecutionPlanMapper

  describe "#to_shell_script/1" do
    test "it converts a list of tasks to a shell_script command pipeline" do
      execution_plan = [
        %{name: "back_one_dir", command: "cd .."},
        %{name: "where_am_i", command: "pwd"}
      ]

      assert ExecutionPlanMapper.to_shell_script(execution_plan) == "#!/usr/bin/env sh\ncd ..;pwd"
    end
  end

  describe "#external/1" do
    test "it converts a list of tasks to its external representation" do
      execution_plan = [
        %{name: "back_one_dir", command: "cd ..", requires: nil},
        %{name: "where_am_i", command: "pwd", requires: ["back_one_dir"]}
      ]

      assert ExecutionPlanMapper.to_external(execution_plan) ==
               [
                 %{name: "back_one_dir", command: "cd .."},
                 %{name: "where_am_i", command: "pwd"}
               ]
    end
  end
end
