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

    GenStage.start_link(__MODULE__, init_opts, name: opts[:name] || __MODULE__)
  end

  def init(queue: queue_name, producers: producers, sqs: sqs) do
    state = %{
      queue: queue_name,
      sqs: sqs
    }

    subscriptions = Enum.map(producers, &{&1, [max_demand: 10]})
    {:consumer, state, subscribe_to: subscriptions}
  end

  @doc """
  Handle events received from producer and do not reply.
  """
  def handle_events(messages, _from, state) do
    handle_messages(messages, state)
    {:noreply, [], state}
  end

  # Handle received messages processing each of them and
  # delete from queue in case of :process response.
  @spec handle_messages([map], map) :: term
  defp handle_messages(messages, state) do
    messages
    |> Enum.map(&process_message/1)
    |> Enum.filter(fn {s, _} -> s == :process end)
    |> Enum.map(fn {_, m} -> m end)
    |> (&state.sqs.delete_message_batch(state.queue, &1)).()
  end

  @doc """
  Process received message, run provided callback for handling it.
  it returns tuple with handling result and following action.
  """
  @spec process_message(map) :: {:process, map} | {:skip | map}
  def process_message(message) do
    body = Poison.decode!(message.body)

    case message.message_attributes do
      %{"provider" => %{value: provider}, "event" => %{value: event}} ->
        event
        |> @event_handler.handle_event(provider, body)
        |> post_process_message(message)

      _ ->
        "unknown-event"
        |> @event_handler.handle_event("unknown-provider", body)
        |> post_process_message(message)
    end
  end

  def child_spec(id, args) do
    %{
      id: id,
      start: {__MODULE__, :start_link, [args]}
    }
  end

  defp post_process_message(:process, message), do: {:process, message}
  defp post_process_message(:skip, message), do: {:skip, message}
end
