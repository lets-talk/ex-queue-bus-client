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
          value: "action"
        },
        %{
          name: "provider",
          data_type: :string,
          value: "nuntium"
        },
        %{
          name: "realm",
          data_type: :string,
          value: "bci"
        },
        %{
          name: "resource",
          data_type: :string,
          value: "resource"
        },
        %{
          name: "roles",
          data_type: :"String.Array",
          value: Poison.encode!(["integration"])
        },
        %{
          name: "type",
          data_type: :string,
          value: "command"
        },
        %{
          name: "version",
          data_type: :number,
          value: 1
        }
      ]
    }

    actual = %{
      payload: %{data: 123},
      event: "resource.action",
      provider: "nuntium",
      roles: ["integration"],
      realm: "bci",
      type: "command"
    }

    assert serialize(actual) == expected
  end
end
