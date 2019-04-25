use Mix.Config

config :ex_queue_bus_client,
  queue: "communication_bus_develop",
  event_handler: ExQueueBusClient.EventHandler

import_config "dev.secret.exs"
