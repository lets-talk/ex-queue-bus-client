use Mix.Config

config :ex_aws,
  access_key_id:      ["${AWS_ACCESS_KEY}", :instance_role],
  secret_access_key:  ["${AWS_SECRET_KEY}", :instance_role],
  region: "us-west-1"

config :ex_queue_bus_client, queue: "${SQS_QUEUE_NAME}"
