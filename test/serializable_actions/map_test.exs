defmodule ExQueueBusClient.MapTest do
  use ExUnit.Case
  import ExQueueBusClient.SerializableAction

  test "map serializes correctly without attributes" do
    expected = {
      Poison.encode!(%{data: 123}),
      []
    }

    assert serialize(%{data: 123}) == expected
  end

  test "map serializes with attributes" do
    expected = {
      Poison.encode!(%{data: 123}),
      [
        %{
          name: "event",
          data_type: :string,
          value: "some_action"
        },
        %{
          name: "provider",
          data_type: :string,
          value: "nuntium"
        }
      ]
    }

    actual = %{
      payload: %{data: 123},
      event: "some_action",
      provider: "nuntium"
    }

    assert serialize(actual) == expected
  end
end
