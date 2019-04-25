defmodule ExQueueBusClient.Application do
  @moduledoc false

  use Application

  alias ExQueueBusClient.SQS.{Producer, Consumer}

  def start(_type, _args) do
    queue = ExQueueBusClient.queue()

    do_not_start_tree = Application.get_env(:ex_queue_bus_client, :do_not_start_tree)

    children = if do_not_start_tree do
      []
    else 
      [
        {Producer, [queue_name: queue]},
        Consumer.child_spec(:sqsc1, [queue_name: queue, producers: [Producer], name: :sqs_consumer_1]),
        Consumer.child_spec(:sqsc2, [queue_name: queue, producers: [Producer], name: :sqs_consumer_2])
      ]
    end

    opts = [strategy: :one_for_one, name: ExQueueBusClient.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
