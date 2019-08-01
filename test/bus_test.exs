defmodule ExQueueBusClient.BusTest do
  use ExUnit.Case, async: false

  defmodule DummyBus do
    use ExQueueBusClient.Bus,
      otp_app: :ex_queue_bus_client,
      event_handler: ExQueueBusClient.EventHandler,
      tx: :sns,
      rx: :sqs
  end

  @settings [consumers_count: 3, sns_topic_arn: "test-topic", sqs_queue_name: "test-queue"]

  setup do
    Application.put_env(:ex_queue_bus_client, ExQueueBusClient.BusTest.DummyBus, @settings)
    :ok
  end

  describe "module that uses Bus" do
    test "it has a start_link/1 function exported" do
      assert function_exported?(DummyBus, :start_link, 1)
    end

    test "it has a child_spec/1 function exported" do
      assert function_exported?(DummyBus, :child_spec, 1)
    end

    test "it has a publish/1 function exported" do
      assert function_exported?(DummyBus, :publish, 1)
    end

    test "it starts bus supervisor with children and correct config" do
      assert {:ok, pid} = DummyBus.start_link()

      assert [
               {"Consumer-3", _, _, _},
               {"Consumer-2", _, _, _},
               {"Consumer-1", _, _, _},
               {ExQueueBusClient.SQS.Producer, _, _, _},
               {ExQueueBusClient.BusSupervisor.Config, _, _, _}
             ] = Supervisor.which_children(pid)

      config =
        @settings
        |> Keyword.put(:event_handler, ExQueueBusClient.EventHandler)
        |> Keyword.put(:tx, :sns)

      assert ^config = ExQueueBusClient.BusSupervisor.Config.config()
    end
  end
end
