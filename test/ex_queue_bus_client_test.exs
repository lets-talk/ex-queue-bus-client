defmodule ExQueueBusClientTest do
  use ExUnit.Case
  doctest ExQueueBusClient

  alias ExQueueBusClient.{
    SNSClientMock,
    AWSClientMock
  }

  import Mox

  setup :verify_on_exit!

  setup do
    AWSClientMock
    |> stub(:request, fn _ -> {:ok, %{}} end)

    :ok
  end

  @tag :integration
  test "AWS SQS responds ok after sending message" do
    Application.put_env(:ex_queue_bus_client, :send_via, nil)
    assert {:ok, _} = ExQueueBusClient.send_action("some action")
  end

  test "sends message via SNS" do
    Application.put_env(:ex_queue_bus_client, :send_via, :sns)

    SNSClientMock
    |> expect(:publish, fn _, _ -> %ExAws.Operation.Query{} end)

    assert {:ok, %{}} = ExQueueBusClient.send_action({"some_action", []})
  end
end
