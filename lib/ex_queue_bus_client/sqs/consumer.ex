defmodule ExQueueBusClient.SQS.Consumer do
  use GenStage
  alias ExQueueBusClient.SQS

  @event_handler Application.get_env(:ex_queue_bus_client, :event_handler)

  def start_link(opts) do
    init_opts = [
      queue: opts[:queue_name],
      producers: opts[:producers],
      sqs: opts[:sqs] || SQS
    ]

    GenStage.start_link(__MODULE__, init_opts, [name: opts[:name] || __MODULE__])
  end

  def init(queue: queue_name, producers: producers, sqs: sqs) do
    state = %{
      queue: queue_name,
      sqs: sqs
    }

    subscriptions = Enum.map(producers, &{&1, [max_demand: 10]})
    {:consumer, state, subscribe_to: subscriptions}
  end

  def handle_events(messages, _from, state) do
    handle_messages(messages, state)
    {:noreply, [], state}
  end

  defp handle_messages(messages, state) do
    messages
    |> Enum.map(&process_message/1)
    |> Enum.filter(fn({s, _}) -> s == :process end)
    |> Enum.map(fn({_, m}) -> m end)
    |> (&state.sqs.delete_message_batch(state.queue, &1)).()
  end

  def process_message(message) do
    %{"event" => event, "provider" => provider, "body" => body} = Poison.decode!(message.body)
    provider = String.to_existing_atom(provider)

    case @event_handler.handle_event(event, provider, body) do
      :process -> {:process, message}
      :skip -> {:skip, message}
    end
  end

  def child_spec(id, args) do
    %{
      id: id,
      start: { __MODULE__, :start_link, [args] }
    }
  end
end
