defmodule ExQueueBusClientTest do
  use ExUnit.Case
  doctest ExQueueBusClient

  @tag :integration
  test "AWS SQS responds ok after sending message as tuple" do
    assert {:ok, _} = ExQueueBusClient.send_action({"some action", []})
  end

  @tag :integration
  test "AWS SQS responds ok after sending message as term" do
    assert {:ok, _} = ExQueueBusClient.send_action("some action")
  end
end
