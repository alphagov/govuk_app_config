# GOV.UK Config

Adds the basics of a GOV.UK application:

- Puma as a web server
- Error reporting with Sentry
- Prometheus monitoring for EKS
- Statsd client for reporting stats (deprecated; use Prometheus instead)
- Rails logging
- Content Security Policy generation for frontend apps

## Installation

Add this line to your application's Gemfile:

```ruby
gem "govuk_app_config"
```

Then run `bundle`.


## Puma

### Configuration

Create a file `config/puma.rb` in the app, containing:

```rb
require "govuk_app_config/govuk_puma"
GovukPuma.configure_rails(self)
```

### Usage

To run an app locally with Puma, run: `bundle exec puma` or `bundle exec rails s`.


## Error reporting

### Automatic error reporting

If you include `govuk_app_config` in your `Gemfile` and set the following environment variables, your application will automatically log errors to Sentry.

- `SENTRY_DSN` - the [Data Source Name (DSN)][dsn] for Sentry
- `SENTRY_CURRENT_ENV` - the `environment` tag to pass to Sentry, for example `production`
- `GOVUK_STATSD_PREFIX` - a Statsd prefix like `govuk.apps.application-name.hostname` (deprecated; statsd functionality will be removed in a future release)

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
`before_send` callback doesn't return `nil`.

```ruby
GovukError.configure do |config|
  config.before_send = ->(event, hint) {
    hint[:exception].is_a?(ErrorWeWantToIgnore) ? nil : event
  }
end
```

`GovukError.configure` has the same options as the Sentry client, Raven. See [the Raven docs for all configuration options](https://docs.sentry.io/clients/ruby/config).

## Open Telemetry

To enable Open Telemetry instrumentation for Rails set the ENABLE_OPEN_TELEMETRY="true" environment variable.

## Prometheus monitoring

Create a `/config/initializers/prometheus.rb` file in the app and add the following

```ruby
require "govuk_app_config/govuk_prometheus_exporter"
GovukPrometheusExporter.configure
```

## Statsd (deprecated)

⚠️ Statsd support is deprecated and will be removed in a future major release of govuk_app_config.

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

To enable production-like logging, an env variable `GOVUK_RAILS_JSON_LOGGING`
is set in the `govuk-helm-charts` and then checked in `railtie.rb`. This will
allow JSON format logs and `Govuk-Request-Id` to be visible.

For development logs, in order to see the production style logs, developers should
set `GOVUK_RAILS_JSON_LOGGING`in `govuk-docker` -> `docker-compose` files.

### Logger configuration

To include additional custom fields in your Rails logs, you can declare them
within a `GovukJsonLogging.configure` block in a `config/initializers/` file.

Example of adding a key/value to log entries based on a request header:

```ruby
GovukJsonLogging.configure do
  add_custom_fields do |fields|
    fields[:govuk_custom_field] = request.headers["GOVUK-Custom-Header"]
  end
end
```

## Content Security Policy generation

For frontend apps, configuration can be added to generate and serve a
content security policy header. The policy is report only when the
environment variable `GOVUK_CSP_REPORT_ONLY` is set, and enforced otherwise.

To enable this feature, create a file at `config/initializers/csp.rb` in the
app with the following content:

```ruby
GovukContentSecurityPolicy.configure
```

## Internationalisation rules

Some frontend apps support languages that are not defined in the i18n gem. This provides them with our own custom rules for these languages.


## License

[MIT License](LICENCE)
