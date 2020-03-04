defmodule ExQueueBusClient.EventHandler do
  @behaviour ExQueueBusClient.EventHandlerBehaviour

  @doc """
  Default handler definition.
  """
  def handle_event(_, _, %{test: true}, _), do: :process
  def handle_event(_, _, _, _), do: :skip
end
