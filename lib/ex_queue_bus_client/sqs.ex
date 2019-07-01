defmodule ExQueueBusClient.SQS do
  @moduledoc """
  Communication interface between Messenger and AWS SQS.
  """

  require Logger

  @doc """
  Form and delete a batch of messages from AWS SQS.
  """
  @spec delete_message_batch(String.t(), [%{}]) :: {:ok, term} | {:error, term}
  def delete_message_batch(queue, messages) do
    queue
    |> ExAws.SQS.delete_message_batch(Enum.map(messages, &make_batch_item/1))
    |> ExAws.request()
  end

  @doc """
  Send message to AWS SQS.
  """
  @spec send_message(String.t(), {String.t(), [map]}) :: {:ok, term} | {:error, term}
  def send_message(queue, {message, attributes}) do
    Logger.info("Sending message to SQS: #{inspect(message)}.")

    queue
    |> ExAws.SQS.send_message(message, message_attributes: attributes)
    |> ExAws.request()
  end

  @doc """
  Receives messages from AWS SQS.
  """
  @spec receive_message(String.t(), ExAws.SQS.receive_message_opts()) ::
          {:ok, term} | {:error, term}
  def receive_message(queue, opts \\ []) do
    queue
    |> ExAws.SQS.receive_message(opts)
    |> ExAws.request()
  end

  @doc """
  Create new AWS SQS queue.
  """
  @spec create_queue(String.t()) :: {:ok, term} | {:error, term}
  def create_queue(name) do
    name
    |> ExAws.SQS.create_queue()
    |> ExAws.request()
  end

  defp make_batch_item(message) do
    %{id: Map.get(message, :message_id), receipt_handle: Map.get(message, :receipt_handle)}
  end
end
