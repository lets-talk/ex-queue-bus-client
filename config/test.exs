use Mix.Config

config :ex_queue_bus_client,
  sns_client: ExQueueBusClient.SNSClientMock,
  aws_client: ExQueueBusClient.AWSClientMock,
  config_agent: ExQueueBusClient.ConfigMock

config :ex_aws,
  access_key_id: [System.get_env("AWS_ACCESS_KEY"), :instance_role],
  secret_access_key: [System.get_env("AWS_SECRET_KEY"), :instance_role]
