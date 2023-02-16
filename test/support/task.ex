defmodule Support.Task do
  def build(name, dependencies) do
    %{"name" => name, "command" => "echo #{name}", "requires" => dependencies}
  end

  def build(name) do
    %{"name" => name, "command" => "echo #{name}"}
  end
end
