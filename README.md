Ex Queue Bus Client
===================

[![CircleCI](https://circleci.com/gh/lets-talk/ex-queue-bus-client.svg?style=svg)](https://circleci.com/gh/lets-talk/ex-queue-bus-client)

This elixir library helps microservices communicate with each other through
some external message queue service like AWS SQS. It is designed under the
back pressure pattern and uses GenStage under the hood.

## Installation

Add the following to your dependencies in mix file:

```elixir
def deps do
    [
        {:ex_queue_bus_client, git: "https://github.com/lets-talk/ex-queue-bus-client.git", tag: "0.1.1"}
    ]
end
```

Then run `mix deps.get` command to fetch dependencies.

## Configuration

To use Amazon SQS:

```elixir
use Mix.Config

config :ex_aws,
  access_key_id:      ["${AWS_ACCESS_KEY}", :instance_role],
  secret_access_key:  ["${AWS_SECRET_KEY}", :instance_role],
  region: "us-west-1"

config :ex_queue_bus_client,
    queue: "${SQS_QUEUE_NAME}",
    event_handler: MyApp.EventHandler
```

Event handler is a module where you define how to deal with different incoming
events. For this purpose you should use `handle_event/3` function which must
return `:process` or `:skip` it will let library know whether remove message
from queue or leave it alive waiting.

*EventHandler.ex*

```elixir
defmodule MyApp.EventHandler do

    def handle_event(:important_event, :my_service, %{members_count: 100})
        :process
    end

    def handle_event(_, _, _), do: :skip

end
```

## Usage

This version supports only AWS SQS as a queue service and only Tuple as a
serializable object for sending. But actually you can send any string but it
will cause desorder in your mesages payload.

```elixir
alias ExQueueBusClient.SerializableAction, as: SAction

{:ok, _} =
    {:some_action, %{some: "payload"}}
    |> SAction.serialize()
    |> ExQueueBusClient.send_action()

{:ok, _} = ExQueueBusClient.send_action("any string")
```

## Testing

ExUnit framework was used to test the library. To run tests just
execute `mix test` and to include some integration tests use `mix test --include integration`
but it requires ex_aws config for testing.

## License

[MIT](LICENSE)

