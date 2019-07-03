defmodule ExQueueBusClient.StringTest do
  use ExUnit.Case
  import ExQueueBusClient.SerializableAction

  test "string serializes correctly without attributes" do
    expected = {
      "some_action",
      []
    }

    assert serialize("some_action") == expected
  end
end
