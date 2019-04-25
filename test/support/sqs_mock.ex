defmodule ExQueueBusClient.SqsMock do
  @spec delete_message_batch(String.t(), [%{}]) :: term
  def delete_message_batch(_queue, messages) do
    for _ <- messages, do: send(self(), :deleted)
  end
end
