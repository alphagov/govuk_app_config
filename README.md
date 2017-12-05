# GOV.UK Config

Adds the basics of a GOV.UK application:

- Unicorn as a web server
- Error reporting with Sentry
- Statsd client for reporting stats

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'govuk_app_config'
```

And then execute:

    $ bundle

## Usage

## Unicorn

No configuration required.

## Error reporting

### Automatic error reporting

If you include `govuk_app_config` in your `Gemfile`, Rails' autoloading mechanism will make sure that your application is configured to send errors to Sentry.

If you use the gem outside of Rails you'll have to explicitly require it:

```rb
require 'govuk_app_config'
```

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
  extra: { offending_content_id: '123' }, # Additional context for this event. Must be a hash. Children can be any native JSON type.
  level: 'debug', # debug, info, warning, error, fatal
  tags: { key: 'value' } # Tags to index with this event. Must be a mapping of strings.
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

## License

[MIT License](LICENSE.md)
