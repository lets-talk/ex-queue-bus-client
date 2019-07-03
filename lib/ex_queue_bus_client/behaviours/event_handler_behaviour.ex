defmodule ExQueueBusClient.EventHandlerBehaviour do
  @callback handle_event(binary, binary, map()) :: :process | :skip
end
