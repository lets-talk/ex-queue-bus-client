use Mix.Config

config :ex_queue_bus_client,
  do_not_start_tree: true,
  event_handler: ExQueueBusClient.EventHandlerMock,
  sns_client: ExQueueBusClient.SNSClientMock,
  aws_client: ExQueueBusClient.AWSClientMock,
  sns_topic: "test-topic"

config :ex_aws,
  access_key_id: [System.get_env("AWS_ACCESS_KEY"), :instance_role],
  secret_access_key: [System.get_env("AWS_SECRET_KEY"), :instance_role]
