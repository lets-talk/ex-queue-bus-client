defmodule ExQueueBusClient do
  @moduledoc """
  Documentation for ExQueueBusClient.
  """

  alias ExQueueBusClient.SQS

  @behaviour ExQueueBusClient.SenderBehaviour

  def send_action(action = {_, _}) do
    SQS.send_message(queue(), action)
  end

  def send_action(action) do
    action
    |> ExQueueBusClient.SerializableAction.serialize()
    |> send_action()
  end

  def queue do
    Application.get_env(:ex_queue_bus_client, :queue) || "probando"
  end

  defprotocol SerializableAction do
    @fallback_to_any true
    @spec serialize(any) :: {binary, [map]}
    def serialize(data)
  end
end
