defmodule ExQueueBusClient.TupleTest do
  use ExUnit.Case
  import ExQueueBusClient.SerializableAction

  test "tuple serializes correctly" do
    expected = %{event: "some_action", provider: "nuntium", body: %{data: 123}}
    actual = serialize({:some_action, "nuntium", %{data: 123}})
    assert Poison.decode!(actual, keys: :atoms!) == expected
  end
end
