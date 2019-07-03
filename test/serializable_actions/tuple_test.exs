defmodule ExQueueBusClient.TupleTest do
  use ExUnit.Case
  import ExQueueBusClient.SerializableAction

  test "tuple serializes correctly without target" do
    expected = {
      %{data: 123},
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

    actual = serialize({"some_action", "nuntium", %{data: 123}})
    assert {Poison.decode!(elem(actual, 0), keys: :atoms!), elem(actual, 1)} == expected
  end

  test "tuple serializes correctly with target" do
    expected = {
      %{data: 123},
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
        },
        %{
          name: "target",
          data_type: :string,
          value: "letstalk"
        }
      ]
    }

    actual = serialize({"some_action", "nuntium", %{data: 123}, "letstalk"})
    assert {Poison.decode!(elem(actual, 0), keys: :atoms!), elem(actual, 1)} == expected
  end
end
