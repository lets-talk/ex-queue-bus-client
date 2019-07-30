defimpl ExQueueBusClient.SerializableAction, for: Map do
  def serialize(message = %{payload: payload, provider: _, event: event}) do
    [resource, event] =
      case String.split(event, ".") do
        [resource, event] -> [resource, event]
        [event] -> [nil, event]
      end

    {
      Poison.encode!(payload),
      message
      |> Map.put(:event, event)
      |> Map.put_new(:resource, resource)
      |> Map.put_new(:version, 1)
      |> Enum.map(&parse_attribute/1)
      |> Enum.filter(& &1)
    }
  end

  def serialize(payload) do
    {Poison.encode!(payload), []}
  end

  defp parse_attribute({_, nil}), do: nil

  defp parse_attribute({:provider, value}) do
    %{name: "provider", data_type: :string, value: value}
  end

  defp parse_attribute({:event, value}) do
    %{name: "event", data_type: :string, value: value}
  end

  defp parse_attribute({:role, value}) do
    %{name: "role", data_type: :"String.Array", value: Poison.encode!(value)}
  end

  defp parse_attribute({:version, value}) do
    %{name: "version", data_type: :number, value: value}
  end

  defp parse_attribute({:organization, value}) do
    %{name: "organization", data_type: :string, value: value}
  end

  defp parse_attribute({:resource, value}) do
    %{name: "resource", data_type: :string, value: value}
  end

  defp parse_attribute(_), do: nil
end
