defmodule ExQueueBusClient.SNS do
  @moduledoc """
  This module is a collection of functions to
  communicate with AWS SNS service: publish,
  subscribe, etc ...
  """

  require Logger

  @sns_client ExQueueBusClient.sns_client()
  @aws_client ExQueueBusClient.aws_client()

  @doc """
  Send message to SNS topic.
  """
  @spec send_message({binary, [map]}) :: term()
  def send_message({message, attributes}) do
    Logger.info("Sending message to SNS: #{inspect(message)}.")

    message
    |> @sns_client.publish(
      topic_arn: ExQueueBusClient.sns_topic(),
      message_attributes: prepare_attributes(attributes)
    )
    |> @aws_client.request()
  end

  defp prepare_attributes(attrs) do
    Enum.map(attrs, fn %{name: n, value: v, data_type: dt} ->
      %{name: n, data_type: dt, value: {:string, v}}
    end)
  end
end
