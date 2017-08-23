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

If you include `govuk_app_config` in your `Gemfile` your application will be automatically configured to send errors to Sentry.

### Manual error reporting

Report something to Sentry manually:

```rb
GOVUK::Error.notify("Something went terrible")
```

```rb
GOVUK::Error.notify(ArgumentError.new("Or some exception object"))
```

Extra parameters are:

```rb
GOVUK::Error.notify(
  "Oops",
  extra: { offending_content_id: '123' }, # Additional context for this event. Must be a hash. Children can be any native JSON type.
  level: 'debug', # debug, info, warning, error, fatal
  tags: { key: 'value' } # Tags to index with this event. Must be a mapping of strings.
)
```

## License

[MIT License][LICENSE.md]
