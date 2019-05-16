defmodule ExQueueBusClient.SQS.ProducerTest do
  use ExUnit.Case, async: true

  alias ExAws.SQS
  alias ExQueueBusClient.SQS.Producer

  @queue "ExQueueBusClient-SQS-ProducerTest"

  describe "when receives :ssl_closed message" do
    test "it returns no events and same state" do
      state = %{demand: 20}
      assert {:noreply, [], ^state} =
        Producer.handle_info({:ssl_closed, {:a, :b}}, state)
    end
  end

  describe "when handles demand" do
    setup do
      queue = "#{@queue}-#{:rand.uniform(1000)}"
      messages = ["Hi!", "Bye!"]
      queue |> SQS.create_queue() |> ExAws.request()

      for m <- messages do
        queue |> SQS.send_message(m) |> ExAws.request()
      end

      on_exit(fn ->
        queue |> SQS.delete_queue() |> ExAws.request()
      end)

      %{queue: queue, messages: messages}
    end


    @tag :integration
    test "it receives all messages", %{messages: expected_messages, queue: queue} do
      {:ok, producer} = Producer.start_link([queue_name: queue])

      messages =
        [producer]
        |> GenStage.stream()
        |> Enum.take(2)
        |> Enum.map(fn m -> m.body end)
        |> Enum.sort()

      assert messages == Enum.sort(expected_messages)
    end
  end
end
