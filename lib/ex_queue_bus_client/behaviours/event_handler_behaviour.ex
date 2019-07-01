defmodule ExQueueBusClient.EventHandlerBehaviour do
  @callback handle_event(event :: binary, provider :: binary, payload :: map()) ::
              :process | :skip
end
