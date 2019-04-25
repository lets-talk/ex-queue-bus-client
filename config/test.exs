use Mix.Config

config :ex_queue_bus_client,
  do_not_start_tree: true,
  event_handler: ExQueueBusClient.EventHandlerMock


import_config "test.secret.exs"
