# GOV.UK Config

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'govuk_app_config'
```

And then execute:

    $ bundle

## Usage

### Automatic error reporting

If you include `govuk_app_config` in your `Gemfile`, Rails' autoloading mechanism will make sure that your application is configured to send errors to Sentry.

If you use the gem outside of Rails you'll have to explicitly require it:

```rb
require 'govuk_app_config/configure'
```

Your app will have to have the following environment variables set:

- `SENTRY_DSN` - the [Data Source Name (DSN)][dsn] for Sentry
- `SENTRY_CURRENT_ENV` - production, staging or integration
- `GOVUK_STATSD_PREFIX` - a Statsd prefix like `govuk.apps.application-name`

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

### Capture filtering

If you need to have fine-grained control over which exceptions are reported to Sentry,
and cannot make use of [`excluded_exceptions`][sentry_docs], then this gem exposes
configuration for determining what should and should not be reported.

This takes the form of a chain of "capture filters". A capture filter is a `Proc`
that accepts the Sentry error, and returns `true` if the error **should** be reported:

```rb
GovukError.configure do |config|
  config.add_capture_filter do |error|
    return true unless ExampleErrorHandler.should_ignore?(error)
  end
end
```

Note that all capture filters will be run against all raised errors, and if **any** of
them return something falsy, then the error will **not** be reported.

[sentry_docs]: https://docs.sentry.io/clients/ruby/config/

## License

[MIT License](LICENSE.md)
