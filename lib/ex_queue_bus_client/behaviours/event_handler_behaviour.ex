defmodule ExQueueBusClient.EventHandlerBehaviour do
  @callback handle_event(binary, binary, map(), map()) :: :process | :skip
end
