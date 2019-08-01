defmodule ExQueueBusClient.Bus do
  @moduledoc """
  Defines a transport and ways of sending and receiving
  messages between micro-services.

  When used, Bus expects `:otp_app` OTP application that uses
  this library and that has transport configuration to be provided,
  also two options `:tx` which defines a way to send messages
  that can be SNS or SQS and `:rx` which defines a way
  to receive messages, only SQS for now. For example, the bus:

    defmodule MyApp.Bus do
      use ExQueueBusClient.Bus,
        otp_app: :my_app,
        event_handler: MyApp.EventHandler,
        tx: :sns,
        rx: :sqs
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
      @tx Keyword.get(opts, :tx)
      @rx Keyword.get(opts, :rx, :sqs)
      @event_handler Keyword.get(opts, :event_handler)

      def start_link(opts \\ []) do
        ExQueueBusClient.BusSupervisor.start_link(
          __MODULE__,
          @otp_app,
          @event_handler,
          @rx,
          @tx,
          opts
        )
      end

      def child_spec(_) do
        %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, []}
        }
      end

      def publish(event) do
        ExQueueBusClient.send_action(event)
      end
    end
  end

  @type event :: tuple | map | binary | any

  @callback start_link(opts :: Keyword.t()) ::
              {:ok, pid}
              | {:error, {:already_started, pid}}
              | {:error, term}

  @callback child_spec(term) :: map

  @callback publish(event) :: {:ok, term} | {:error, term}
end
