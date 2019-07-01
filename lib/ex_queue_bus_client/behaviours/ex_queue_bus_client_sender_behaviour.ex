defmodule ExQueueBusClient.SenderBehaviour do
  @moduledoc """
  External action sender.
  """

  @doc """
  Send a serialized action
  """
  @callback send_action({binary, Keyword.t()} | term) ::
              {binary, [map]} | {:ok, term()} | {:error, term()}
end
