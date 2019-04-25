defimpl ExQueueBusClient.SerializableAction, for: Tuple do
  def serialize({name, provider, payload = %{}}) do
    Poison.encode!(%{event: name, provider: provider, body: payload})
  end
end
