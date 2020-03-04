CHANGELOG
=========

## Release [3.0.0] - 04.03.2020
### Added
- New message attribute `Type` to handle.
### Changed
- Pass all attributes to handle_event function as a fourth argument.

## Hotfix [2.0.2] - 16.01.2020
### Fixed
- Fix hacney version to get reed of ssl problem.

## Hotfix [2.0.1] - 01.08.2019
### Fixed
- Use real modules when mocks are not defined without app env.

### Added
- Childspec for Bus.
- Delegate `Bus.publish/1` to `ExQueueBusClient.send_action/1`.

## Release [2.0.0] - 31.07.2019
### Fixed
- Configuration system is now callback based.
### Added
- Support for more message attributes.
### Changed
- Message format.

## Hotfix [1.0.1] - 05.07.2019
### Fixed
- Dependency injection for testing with mocks. Ensure to
  use real modules in application that use this library.

## Release [1.0.0] - 03.07.2019
### Changed
- How messages are sent via SQS, structure, attributes.
- How messages are receieved and handled.
- Provider now is a string argument of handle_event/3.
### Added
- AWS SNS publishing integration.

## Release [0.2.0] - 16.05.2019
### Added
- CircleCI integration.

## Hotfix [0.1.1] - 15.05.2019
### Fixed
- OTP21 `:ssl_closed` message handling in Producer.

## Release [0.1.0] - 25.04.2019
### Added
- First released version with SQS support.
