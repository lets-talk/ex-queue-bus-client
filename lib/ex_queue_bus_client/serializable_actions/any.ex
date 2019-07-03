defimpl ExQueueBusClient.SerializableAction, for: Any do
  def serialize(_) do
    {Poison.encode!(%{event: "Undefined", provider: "Undefined", payload: %{}}), []}
  end
end
