defimpl ExQueueBusClient.SerializableAction, for: BitString do
  def serialize(data) do
    {data, []}
  end
end
