defimpl ExQueueBusClient.SerializableAction, for: Map do
  def serialize(%{payload: payload, provider: provider, event: event}) do
    {
      Poison.encode!(payload),
      [
        %{name: "event", data_type: :string, value: event},
        %{name: "provider", data_type: :string, value: provider}
      ]
    }
  end

  def serialize(payload) do
    {Poison.encode!(payload), []}
  end
end
