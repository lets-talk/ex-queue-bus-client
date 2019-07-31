defmodule ExQueueBusClient.SQS.ProducerTest do
  use ExUnit.Case, async: true

  alias ExAws.SQS
  alias ExQueueBusClient.SQS.Producer

  @queue "ExQueueBusClient-SQS-ProducerTest"

  describe "when receives :ssl_closed message" do
    test "it returns no events and same state" do
      state = %{demand: 20}
      assert {:noreply, [], ^state} = Producer.handle_info({:ssl_closed, {:a, :b}}, state)
    end
  end

  describe "when handles demand" do
    setup do
      queue = "#{@queue}-#{:rand.uniform(1000)}"
      messages = ["Hi!", "Bye!"]

      attributes = [
        %{name: "provider", data_type: :string, value: "letstalk"},
        %{name: "event", data_type: :string, value: "create"},
        %{name: "resource", data_type: :string, value: "message"},
        %{name: "version", data_type: :string, value: "1"},
        %{name: "roles", data_type: :"String.Array", value: "['foo', 'bar']"},
        %{name: "target", data_type: :string, value: "ex_queue_bus_client"}
      ]

      queue |> SQS.create_queue() |> ExAws.request()

      for m <- messages do
        queue |> SQS.send_message(m, message_attributes: attributes) |> ExAws.request()
      end

      on_exit(fn ->
        queue |> SQS.delete_queue() |> ExAws.request()
      end)

      %{queue: queue, messages: messages, attrs: attributes}
    end

    @tag :integration
    test "it receives all messages", %{messages: messages, queue: queue} do
      {:ok, producer} = Producer.start_link(queue_name: queue)

      expected_messages =
        for m <- messages, into: [] do
          {
            m,
            %{
              "provider" => "letstalk",
              "event" => "create",
              "resource" => "message",
              "version" => "1",
              "roles" => "['foo', 'bar']",
              "target" => "ex_queue_bus_client"
            }
          }
        end

      messages =
        [producer]
        |> GenStage.stream()
        |> Enum.take(2)
        |> Enum.map(fn m ->
          {
            m.body,
            %{
              "provider" => m.message_attributes["provider"].value,
              "event" => m.message_attributes["event"].value,
              "resource" => m.message_attributes["resource"].value,
              "version" => m.message_attributes["version"].value,
              "roles" => m.message_attributes["roles"].value,
              "target" => m.message_attributes["target"].value
            }
          }
        end)
        |> Enum.sort()

      assert messages == Enum.sort(expected_messages)
    end
  end
end
