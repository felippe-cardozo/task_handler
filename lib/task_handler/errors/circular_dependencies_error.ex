defmodule TaskHandler.Errors.CircularDependenciesError do
  defexception message: "Circular Dependencies were found among the tasks"
end
