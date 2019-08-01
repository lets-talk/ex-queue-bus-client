defmodule ExQueueBusClient.BusSupervisor do
  @moduledoc false
  use Supervisor

  alias ExQueueBusClient.SQS.{Producer, Consumer}

  @doc """
  Starts gen stage system supervisor.
  """
  def start_link(bus, otp_app, handler, rx, tx, opts) do
    name = Keyword.get(opts, :name, bus)

    Supervisor.start_link(__MODULE__, {name, bus, otp_app, handler, rx, tx, opts}, name: name)
  end

  @doc """
  Reads Bus configuration from Application environment.
  """
  def config(bus, otp_app) do
    Application.get_env(otp_app, bus, [])
  end

  ## Callbacks

  @doc false
  @impl true
  def init({_name, bus, otp_app, handler, rx, tx, _opts}) do
    config =
      bus
      |> config(otp_app)
      |> Keyword.put(:event_handler, handler)
      |> Keyword.put(:tx, tx)

    children = [
      {ExQueueBusClient.BusSupervisor.Config, config} | receive_mechanism(rx, config)
    ]

    Supervisor.init(children, strategy: :one_for_one, max_restarts: 0)
  end

  defp receive_mechanism(:sqs, config) do
    consumers_count = Keyword.get(config, :consumers_count, 2)
    consumers_count = if consumers_count <= 0, do: 2, else: consumers_count

    queue = config[:sqs_queue_name]
    handler = config[:event_handler]

    [{Producer, [queue_name: queue]}] ++
      for n <- 1..consumers_count, into: [] do
        Consumer.child_spec("Consumer-#{n}",
          queue_name: queue,
          producers: [Producer],
          event_handler: handler
        )
      end
  end

  defp receive_mechanism(_, _), do: raise("Unsupported receiving mechanism.")

  # This is a simple Agent that stores config in it's state.
  defmodule Config do
    @moduledoc false
    use Agent

    @callback start_link(config :: Keyword.t()) :: {:ok, pid} | {:error, term}
    @callback config() :: Keyword.t()

    def start_link(config) do
      Agent.start_link(fn -> config end, name: ExQueueBusClient.Config)
    end

    def config do
      Agent.get(ExQueueBusClient.Config, fn state -> state end)
    end
  end
end
