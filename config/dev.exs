use Mix.Config

config :ex_aws,
  access_key_id: ["${AWS_ACCESS_KEY}", :instance_role],
  secret_access_key: ["${AWS_SECRET_KEY}", :instance_role],
  region: "${AWS_REGION}"

config :ex_queue_bus_client,
  queue: "${SQS_QUEUE_NAME}",
  event_handler: ExQueueBusClient.EventHandler,
  sns_client: ExAws.SNS,
  aws_client: ExAws
