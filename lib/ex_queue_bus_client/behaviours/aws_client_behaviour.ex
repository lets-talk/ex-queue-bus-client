defmodule ExQueueBusClient.AWSClientBehaviour do
  @moduledoc """
  This is a communication interface between ExQueueBusClient
  and AWS services. We implement this behaviour to
  establish a contract and to easiely test it with mocks.
  """

  @callback request(ExAws.Operation.t()) :: {:ok, term} | {:error, term}
end
