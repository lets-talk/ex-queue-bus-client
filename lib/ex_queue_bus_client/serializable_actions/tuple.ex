defimpl ExQueueBusClient.SerializableAction, for: Tuple do
  def serialize({name, provider, payload = %{}}) do
    {
      Poison.encode!(payload),
      [
        %{name: "event", data_type: :string, value: name},
        %{name: "provider", data_type: :string, value: provider}
      ]
    }
  end

  def serialize({name, provider, payload = %{}, target}) do
    {
      Poison.encode!(payload),
      [
        %{name: "event", data_type: :string, value: name},
        %{name: "provider", data_type: :string, value: provider},
        %{name: "target", data_type: :string, value: target}
      ]
    }
  end
end
