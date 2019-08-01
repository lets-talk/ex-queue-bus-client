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
        {:ex_queue_bus_client, git: "https://github.com/lets-talk/ex-queue-bus-client.git", tag: "2.0.1"}
    ]
end
```

Then run `mix deps.get` command to fetch dependencies.

## Configuration

Library includes `ex_aws` as a dependency, so to use it you need to add
a configuration to your `Mix.Config`:

```elixir
use Mix.Config

config :ex_aws,
  access_key_id:      [System.get_env("AWS_ACCESS_KEY"), :instance_role],
  secret_access_key:  [System.get_env("AWS_SECRET_KEY"), :instance_role],
  region: System.get_env("AWS_REGION")
```

To configure your bus you need to create a module like following:

```elixir
defmodule MyApp.Bus do
  use ExQueueBusClient.Bus,
    otp_app: :my_app,
    event_handler: MyApp.EventHandler,
    send_via: :sns,
    receive_with: :sqs
end
```

and according to your `:send_via` and `:receive_with` parameters add config to
your `Mix.Config`:

```elixir
config :my_app, MyApp.Bus,
  consumers_count: 5, # number of workers to process messages, by default 2
  sqs_queue_name: "queue",
  sns_topic_arn: "long topic arn"
```

Then you should add your bus to the supervision tree:

```elixir
  def start(_, _) do
    children = [
      MyApp.Bus
    ]

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
```

Event handler is a module where you define how to deal with different incoming
events. For this purpose you should use `handle_event/3` function which must
return `:process` or `:skip` it will let library know whether remove message
from queue or leave it alive waiting.

*EventHandler.ex*

```elixir
defmodule MyApp.EventHandler do

    def handle_event("important_event", "my_service", %{members_count: 100})
        :process
    end

    def handle_event(_, _, _), do: :skip

end
```

## Message Meta Attributes

Several message attributes are defined and supported by `ExQueueBusClient` these are:

- `:event` of type `:string`
- `:resource` of type `:string`
- `:provider` of type `:string`
- `:roles` of type `:"String.Array"`
- `:version` of type `:number`
- `:organization` of type `:string`

### Event and Resource

That is the resource, the event subject. When you receive message with defined `:event` and `:resource` attributes, `ExQueueBusClient` join these two with `"."` and `handle_event/3` will receive `"resource.event"` as en event argument.

Also when you send message and set the `event` key of a map the library will automatically try to split your event into resource and event if resource is not explicitely defined. 

If neither event nor resource are defined `handle_event/3` will receive `"unknown-event"` as en event argument.

### Provider

Name of a micro service that sent a message. This attribute when defined is passed to `handle_event/3` as a second argument, when not defined `handle_event/3` will receive `"unknown-provider"` as a provider argument. 

### Version

With this number attribute you can control different message's payloads depending of the api version.

## Usage

### RX

Just define `handle_event/3` callback clauses at your event handler module and you are good with this.

### TX

This version supports:

- AWS SQS as a queue service for sending and receiving.
- AWS SNS for sending.

```elixir
{:ok, _response} = MyApp.Bus.publish(%{
  payload: %{content: "Hello folks !"},
  event: "message.create",
  provider: "my_app"
})
```

## Testing

ExUnit framework was used to test the library. To run tests just
execute `mix test` and to include some integration tests use `mix test --include integration`
but it requires ex_aws config for testing.

## License

[MIT](LICENSE)

