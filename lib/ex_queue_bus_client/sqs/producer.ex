defmodule ExQueueBusClient.SQS.Producer do
  use GenStage

  alias ExQueueBusClient.SQS

  @message_attributes [:version, :provider, :target, :event, :resource, :organization, :role]

  def start_link(opts) do
    opts = Keyword.put(opts, :sqs, opts[:sqs] || SQS)
    GenStage.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(sqs: sqs, queue_name: queue_name) do
    state = %{
      demand: 0,
      queue: queue_name,
      sqs: sqs
    }

    {:producer, state}
  end

  def handle_demand(incoming_demand, %{demand: 0} = state) do
    new_demand = state.demand + incoming_demand

    Process.send(self(), :get_messages, [])

    {:noreply, [], %{state | demand: new_demand}}
  end

  def handle_demand(incoming_demand, state) do
    new_demand = state.demand + incoming_demand

    {:noreply, [], %{state | demand: new_demand}}
  end

  def handle_info(:get_messages, state) do
    aws_resp =
      state.queue
      |> state.sqs.receive_message(
        message_attribute_names: @message_attributes,
        max_number_of_messages: min(state.demand, 10)
      )

    messages =
      case aws_resp do
        {:ok, resp} ->
          resp.body.messages

        {:error, _reason} ->
          # You probably want to handle errors differently than this.
          []
      end

    num_messages_received = Enum.count(messages)
    new_demand = max(state.demand - num_messages_received, 0)

    cond do
      new_demand == 0 ->
        :ok

      num_messages_received == 0 ->
        Process.send_after(self(), :get_messages, 200)

      true ->
        Process.send(self(), :get_messages, [])
    end

    {:noreply, messages, %{state | demand: new_demand}}
  end

  @doc """
  This is a workaround to avoid failure from ssl_closed
  message after upgrade OTP.
  """
  def handle_info({:ssl_closed, _}, state) do
    {:noreply, [], state}
  end
end
