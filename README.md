# GOV.UK Config

Adds the basics of a GOV.UK application:

- Unicorn as a web server
- Error reporting with Sentry
- Statsd client for reporting stats
- Rails logging

## Installation

Add this line to your application's Gemfile:

```ruby
gem "govuk_app_config"
```

And then execute:

    $ bundle


## Unicorn

### Configuration

Find or create a `config/unicorn.rb` in the app

At the start of the file insert:

```rb
require "govuk_app_config/govuk_unicorn"
GovukUnicorn.configure(self)
```

### Usage

To serve an app with unicorn run:

```sh
$ bundle exec unicorn -c config/unicorn.rb
```

## Error reporting

### Automatic error reporting

If you include `govuk_app_config` in your `Gemfile`, Rails' autoloading mechanism will make sure that your application is configured to send errors to Sentry.

Your app will have to have the following environment variables set:

- `SENTRY_DSN` - the [Data Source Name (DSN)][dsn] for Sentry
- `SENTRY_CURRENT_ENV` - production, staging or integration
- `GOVUK_STATSD_PREFIX` - a Statsd prefix like `govuk.apps.application-name.hostname`

[dsn]: https://docs.sentry.io/quickstart/#about-the-dsn

### Manual error reporting

Report something to Sentry manually:

```rb
GovukError.notify("Something went terribly wrong")
```

```rb
GovukError.notify(ArgumentError.new("Or some exception object"))
```

Extra parameters are:

```rb
GovukError.notify(
  "Oops",
  extra: { offending_content_id: "123" }, # Additional context for this event. Must be a hash. Children can be any native JSON type.
  level: "debug", # debug, info, warning, error, fatal
  tags: { key: "value" } # Tags to index with this event. Must be a mapping of strings.
)
```

### Error configuration

You can exclude certain errors from being reported using this:

```ruby
GovukError.configure do |config|
  config.excluded_exceptions << "RetryableError"
end
```

`GovukError.configure` has the same options as the Sentry client, Raven. See [the Raven docs for all configuration options](https://docs.sentry.io/clients/ruby/config).

## Statsd

Use `GovukStatsd` to send stats to graphite. It has the same interface as [the Ruby Statsd client](https://github.com/reinh/statsd).

Examples:

```ruby
GovukStatsd.increment "garets"
GovukStatsd.timing "glork", 320
GovukStatsd.gauge "bork", 100

# Use {#time} to time the execution of a block
GovukStatsd.time("account.activate") { @account.activate! }
```

## Healthchecks

Set up a route in your rack-compatible Ruby application, and pick the built-in
or custom checks you wish to perform.

Custom checks must be any object which responds to `#call`.

For Rails apps:
```ruby
module CustomCheck
  def self.call
    {
      my_custom_check: {
        status: ThingChecker.everything_okay? ? "OK" : "Critical"
      }
    }
  end
end
```
```ruby
get "/healthcheck", to: GovukHealthcheck.rack_response(
  GovukHealthcheck::SidekiqRedis,
  GovukHealthcheck::ActiveRecord,
  CustomCheck,
)
```

This will check:
- Redis connectivity (via Sidekiq)
- Database connectivity (via ActiveRecord)
- Your custom healthcheck

## Rails logging

In Rails applications, the application will be configured to send JSON-formatted
logs to `STDOUT` and unstructed logs to `STDERR`.

## License

[MIT License](LICENSE.md)
