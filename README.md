# GOV.UK Config

Adds the basics of a GOV.UK application:

- Unicorn as a web server
- Error reporting with Sentry
- Statsd client for reporting stats
- Rails logging
- Content Security Policy generation for frontend apps

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

And you can exclude errors from being reported if they occur during the nightly data sync (on integration and staging):

```ruby
GovukError.configure do |config|
  config.data_sync_excluded_exceptions << "PG::Error"
end
```

Finally, you can pass your own callback to evaluate whether or not to capture the exception.
Note that if an exception is on the `excluded_exceptions` list, or on the `data_sync_excluded_exceptions`
and occurs at the time of a data sync, then it will be excluded even if the custom
`should_capture` callback returns `true`.

```ruby
GovukError.configure do |config|
  config.should_capture = lambda do |error_or_event|
    error_or_event == "do capture"
  end
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

## Health Checks

This Gem provides a common "health check" framework for apps. See [the health
check docs](docs/healthchecks.md) for more information on how to use it.

## Rails logging

In Rails applications, the application will be configured to send JSON-formatted
logs to `STDOUT` and unstructed logs to `STDERR`.

## Content Security Policy generation

For frontend apps, configuration can be added to generate and serve a
content security policy header. The policy is report only when the
environment variable `GOVUK_CSP_REPORT_ONLY` is set, and enforced otherwise.

To enable this feature, create a file at `config/initializers/csp.rb` in the
app with the following content:

```ruby
GovukContentSecurityPolicy.configure
```

## License

[MIT License](LICENSE.md)
