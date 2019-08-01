defmodule ExQueueBusClient do
  @moduledoc """
  Documentation for ExQueueBusClient.
  """

  alias ExQueueBusClient.{
    SQS,
    SNS
  }

  @behaviour ExQueueBusClient.SenderBehaviour

  def send_action(action = {_, _}) do
    send_via(tx_transport(), action)
  end

  def send_action(action) do
    action
    |> ExQueueBusClient.SerializableAction.serialize()
    |> send_action()
  end

  @doc """
  AWS SNS topic to use if SNS is configured.
  """
  @spec sns_topic() :: binary()
  def sns_topic do
    config()
    |> Keyword.get(:sns_topic_arn)
  end

  @doc """
  Get correct SNS client module from config.
  """
  @spec sns_client() :: :atom
  def sns_client do
    Application.get_env(:ex_queue_bus_client, :sns_client) || ExAws.SNS
  end

  @doc """
  Get correct AWS client module from config.
  """
  @spec aws_client() :: :atom
  def aws_client do
    Application.get_env(:ex_queue_bus_client, :aws_client) || ExAws
  end

  def config do
    config_agent =
      Application.get_env(:ex_queue_bus_client, :config_agent) ||
        ExQueueBusClient.BusSupervisor.Config

    config_agent.config()
  end

  defp tx_transport do
    config()
    |> Keyword.get(:send_via)
  end

  defp send_via(:sqs, action) do
    config()
    |> Keyword.get(:sqs_queue_name)
    |> SQS.send_message(action)
  end

  defp send_via(:sns, action) do
    SNS.send_message(action)
  end

  defp send_via(nil, _) do
    raise "Please set outgoing transport to use"
  end

  defprotocol SerializableAction do
    @fallback_to_any true
    @spec serialize(any) :: {binary, [map]}
    def serialize(data)
  end
end
