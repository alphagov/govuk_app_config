# Unreleased

* Ignore `ActionController::UnknownHttpMethod` errors.

# 1.4.1

* Check the inner exception as well for the intermittent failure behaviour
  added in 1.4.0, eg in the case of `ActionView::Template::Error`

# 1.4.0

* Don't log intermittent errors from `gds-api-adapters` in Sentry, count them
  in Graphite instead

# 1.3.2

* Update instructions to suggest that GovukUnicorn should be required directly
  `require "govuk_app_config/govuk_unicorn"` rather than passively through
  `require "govuk_app_config"` to isolate it from other configuration.
* Move STDOUT/STDERR configuration inside GovukLogging module to reduce side
  effects when gem is initialised.

### How to upgrade

* In your applications `config/unicorn.rb` file change
  `require "govuk_app_config"` to `require "govuk_app_config/govuk_unicorn"`

# 1.3.1

* Fix collection of Statsd gauge metrics

# 1.3.0

* Include a class to configure unicorn to the common GOV.UK configuration

### How to upgrade

* Find or create a config/unicorn.rb file in the app
* At the top of the file insert:
  ```rb
  require "govuk_app_config/govuk_unicorn"
  GovukUnicorn.configure(self)
  ```
* If the app has the following, remove it:
  ```rb
  # Load the system-wide standard Unicorn file
  def load_file_if_exists(config, file)
    config.instance_eval(File.read(file)) if File.exist?(file)
  end
  load_file_if_exists(self, "/etc/govuk/unicorn.rb")
  ```

# 1.2.1

* Use `INFO` log level for the default Rails logger

# 1.2.0

* Upgrade unicorn gem from 5.3.1 to 5.4.0

# 1.1.0

* Support statsd methods of decrement, count, timing, set, and batch

# 1.0.0

* Add Unicorn (our web server) as a dependency
* Use version [2.7.0 of the Sentry client][sentry-270].
* Set up logging configuration for Rails applications.
* Don't send `ActionController::BadRequest`  to Sentry

[sentry-270]: https://github.com/getsentry/raven-ruby/commit/ef623824cb0a8a2f60be5fb7e12f80454da54fd7

### How to upgrade

* Remove `gem 'unicorn'` from your Gemfile
* For Rails apps only:
  * Remove `gem 'logstasher'` from your Gemfile
  * Remove all `config.logstasher.*` configs from `config/environments/production.rb`
  * If the app has a `config/initializers/logstash.rb` remove it
  * If the app has any of the following (likely in `config/environments/production.rb`), remove it:
    ```rb
    # Use default logging formatter so that PID and timestamp are not suppressed.
    config.log_formatter = ::Logger::Formatter.new

    # Use a different logger for distributed setups.
    # require 'syslog/logger'
    config.logger = ActiveSupport::TaggedLogging.new(Logger.new($stderr))

    $real_stdout = $stdout.clone
    $stdout.reopen($stderr)
    ```

## 0.3.0

* Add `time` and `gauge` to `GovukStatsd`
* Add `GovukError.configure` as an alias to `Raven.configure`

## 0.2.0

* First actual release with support for Sentry

## 0.1.0

Empty gem.
