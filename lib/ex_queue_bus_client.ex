defmodule ExQueueBusClient do
  @moduledoc """
  Documentation for ExQueueBusClient.
  """

  alias ExQueueBusClient.SQS

  @behaviour ExQueueBusClient.SenderBehaviour

  def send_action(action = {_, _}) do
    SQS.send_message(queue(), action)
  end

  def send_action(action) do
    action
    |> ExQueueBusClient.SerializableAction.serialize()
    |> send_action()
  end

  @doc """
  AWS SQS queue name to use if SQS is configured.
  """
  @spec queue() :: binary
  def queue do
    Application.get_env(:ex_queue_bus_client, :queue) || "probando"
  end

  @doc """
  AWS SNS topic to use if SNS is configured.
  """
  @spec sns_topic() :: binary()
  def sns_topic do
    Application.get_env(:ex_queue_bus_client, :sns_topic)
  end

  @doc """
  Get correct SNS client module from config.
  """
  @spec sns_client() :: :atom
  def sns_client do
    Application.get_env(:ex_queue_bus_client, :sns_client)
  end

  @doc """
  Get correct AWS client module from config.
  """
  @spec aws_client() :: :atom
  def aws_client do
    Application.get_env(:ex_queue_bus_client, :aws_client)
  end

  defprotocol SerializableAction do
    @fallback_to_any true
    @spec serialize(any) :: {binary, [map]}
    def serialize(data)
  end
end
