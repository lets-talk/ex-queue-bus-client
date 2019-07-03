defmodule ExQueueBusClient.SNSTest do
  use ExUnit.Case, async: true

  alias ExQueueBusClient.{
    SNS,
    SNSClientMock,
    AWSClientMock
  }

  import Mox

  setup :verify_on_exit!

  describe "when publishes to topic" do
    test "it makes a correct request to AWS" do
      query = %ExAws.Operation.Query{}
      payload = %{"content" => "Hello"}
      topic = ExQueueBusClient.sns_topic()

      attributes = [
        %{
          name: "provider",
          data_type: :string,
          value: "nuntium"
        }
      ]

      expected_attributes = [
        %{
          name: "provider",
          data_type: :string,
          value: {:string, "nuntium"}
        }
      ]

      SNSClientMock
      |> expect(:publish, fn ^payload,
                             topic_arn: ^topic,
                             message_attributes: ^expected_attributes ->
        query
      end)

      AWSClientMock
      |> expect(:request, fn ^query -> {:ok, ""} end)

      assert {:ok, _} = SNS.send_message({payload, attributes})
    end
  end
end
