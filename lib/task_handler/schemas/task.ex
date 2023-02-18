defmodule TaskHandler.Schemas.Task do
  def schema do
    %{
      name: [type: :string, required: true],
      requires: [type: {:array, :string}],
      command: [type: :string, required: true]
    }
  end

  def api_in_schema do
    %{tasks: [type: {:array, schema()}]}
  end

  def out_schema do
    %{
      name: [type: :string, required: true],
      command: [type: :string, required: true]
    }
  end
end
