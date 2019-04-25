defmodule ExQueueBusClient.SenderBehaviour do
  @moduledoc """
  External action sender.
  """

  @doc """
  Send a serialized action
  """
  @callback send_action(String.t()) :: {:ok} | {:error, String.t()}

end
