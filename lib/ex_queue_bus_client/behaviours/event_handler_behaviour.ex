defmodule ExQueueBusClient.EventHandlerBehaviour do
  @type event :: String.t()
  @type provider :: :letstalk | :nuntium | :hangout

  @callback handle_event(event, provider, map()) :: :process | :skip
end
