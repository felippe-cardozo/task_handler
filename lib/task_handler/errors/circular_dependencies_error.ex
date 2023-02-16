defmodule TaskHandler.Errors.CircularDependenciesError do
  defexception message: "circular dependencies were found among the tasks"
end
