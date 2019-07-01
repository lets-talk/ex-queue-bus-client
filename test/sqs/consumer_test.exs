defmodule ExQueueBusClient.SQS.ConsumerTest do
  use ExUnit.Case, async: false

  alias ExQueueBusClient.{
    SqsMock,
    SQS.Consumer,
    EventHandlerMock
  }

  import Mox

  setup [:verify_on_exit!, :set_mox_global]

  setup do
    messages =
      ["M1", "M2"]
      |> Enum.map(&build_message("create_message", &1))

    %{messages: messages}
  end

  describe "handle_events/3" do
    test "processes message", %{messages: messages} do
      opts = [queue: "test", producers: [], sqs: SqsMock]
      {:consumer, state, subscribe_to: []} = Consumer.init(opts)

      EventHandlerMock
      |> expect(:handle_event, fn "create_message", "letstalk", %{"content" => "M1"} ->
        :process
      end)
      |> expect(:handle_event, fn "create_message", "letstalk", %{"content" => "M2"} -> :skip end)

      assert {:noreply, [], ^state} = Consumer.handle_events(messages, self(), state)
      assert_receive :deleted
      refute_receive :deleted
    end
  end

  defp build_message(event, body) do
    %{
      attributes: [],
      body: Poison.encode!(%{content: body}),
      md5_of_body: "2d8514fd568c4038110b487bc5cba784",
      message_attributes: %{
        "provider" => %{
          name: "provider",
          value: "letstalk"
        },
        "event" => %{
          name: "event",
          value: event
        }
      },
      message_id: "8c1c0a71-20d6-4c44-b872-b032f51315d8",
      receipt_handle: "some long bullshit"
    }
  end
end
