defmodule ExQueueBusClient.Bus do
  @moduledoc """
  Defines a transport and ways of sending and receiving
  messages between micro-services.

  When used, Bus expects `:otp_app` OTP application that uses
  this library and that has transport configuration to be provided,
  also two options `:send_via` which defines a way to send messages
  that can be SNS or SQS and `:receive_with` which defines a way
  to receive messages, only SQS for now. For example, the bus:

    defmodule MyApp.Bus do
      use ExQueueBusClient.Bus,
        otp_app: :my_app,
        event_handler: MyApp.EventHandler,
        send_via: :sns,
        receive_with: :sqs
    end

  Could be configured with:

    config :my_app, MyApp.Bus,
      consumers_count: 5,
      sqs_queue_name: "my-app-queue",
      sns_topic_arn: "my-app-topic"
  """

  @doc false
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @behaviour ExQueueBusClient.Bus

      @otp_app Keyword.get(opts, :otp_app)
      @send_via Keyword.get(opts, :send_via)
      @receive_with Keyword.get(opts, :receive_with, :sqs)
      @event_handler Keyword.get(opts, :event_handler)

      def start_link(opts \\ []) do
        ExQueueBusClient.BusSupervisor.start_link(
          __MODULE__,
          @otp_app,
          @event_handler,
          @receive_with,
          @send_via,
          opts
        )
      end

      def child_spec(_) do
        %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, []}
        }
      end
    end
  end

  @type event :: tuple | map | binary | any

  @callback start_link(opts :: Keyword.t()) ::
              {:ok, pid}
              | {:error, {:already_started, pid}}
              | {:error, term}

  @callback child_spec(term) :: map
end
