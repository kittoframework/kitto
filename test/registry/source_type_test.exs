defmodule Kitto.Registry.SourceTypeTest do
  use ExUnit.Case, async: true

  alias Kitto.Registry.SourceType

  setup do
    {:ok, source_type} = SourceType.start_link
    {:ok, source_type: source_type}
  end

  test "can store a key and value", %{source_type: source_type} do
    key = "hello_world"

    assert Enum.empty? SourceType.get(source_type)
    SourceType.put source_type, key, %{}, fn() -> true end
    assert !Enum.empty? SourceType.get(source_type)
    {_definition, block, _context} = SourceType.get source_type, key
    assert block.()
  end
end
