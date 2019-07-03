defmodule ExQueueBusClient.SNSClientBehaviour do
  @moduledoc """
  This is a communication interface between ExQueueBusClient
  and AWS SNS service. We implement this behaviour to
  establish a contract and to easiely test it with mocks.
  """

  @callback publish(message :: binary(), opts :: ExAws.SNS.publish_opts()) ::
              ExAws.Operation.Query.t()
end
