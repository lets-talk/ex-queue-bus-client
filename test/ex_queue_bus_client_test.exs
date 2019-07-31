defmodule ExQueueBusClientTest do
  use ExUnit.Case
  doctest ExQueueBusClient

  alias ExQueueBusClient.{
    SNSClientMock,
    AWSClientMock,
    ConfigMock
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
    ConfigMock
    |> expect(:config, 2, fn -> [send_via: :sqs, sqs_queue_name: "probando"] end)

    assert {:ok, _} = ExQueueBusClient.send_action("some action")
  end

  test "sends message via SNS" do
    ConfigMock
    |> expect(:config, 2, fn -> [send_via: :sns, sns_topic_arn: "test_topic"] end)

    SNSClientMock
    |> expect(:publish, fn _, _ -> %ExAws.Operation.Query{} end)

    assert {:ok, %{}} = ExQueueBusClient.send_action({"some_action", []})
  end

  test "raises error when tx transport is not set" do
    ConfigMock
    |> expect(:config, fn -> [send_via: nil] end)

    assert_raise RuntimeError, "Please set outgoing transport to use", fn ->
      ExQueueBusClient.send_action({"some_action", []})
    end
  end
end
