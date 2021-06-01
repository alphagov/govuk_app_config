# 3.1.2

- Attempt to fix the `before_send` behaviour for errors which occur during the data sync ([#198](https://github.com/alphagov/govuk_app_config/pull/198))

# 3.1.1

- Fix the new before_send behaviour & tests, and add documentation ([#197](https://github.com/alphagov/govuk_app_config/pull/197))

# 3.1.0

- Remove support for `should_capture` callbacks in favour of `before_send` ([#196](https://github.com/alphagov/govuk_app_config/pull/196))

# 3.0.0

* BREAKING: Implement RFC 141 - remove unsuitable healthchecks and return a 500 on healthcheck failure ([#193](https://github.com/alphagov/govuk_app_config/pull/193))

# 2.10.0
* Allow LUX domain on img-src policy ([#191](https://github.com/alphagov/govuk_app_config/pull/191))

# 2.9.1

* Fixes bug in GovukI18n introduced in the last version ([#189](https://github.com/alphagov/govuk_app_config/pull/189))

# 2.9.0

* Add GovukI18n module with custom plural rules ([#187](https://github.com/alphagov/govuk_app_config/pull/187))

# 2.8.4

* Ensure Redis healthcheck avoids potential race condition ([#185](https://github.com/alphagov/govuk_app_config/pull/185))

# 2.8.3

* Add new Redis healthcheck and relevant tests ([#183](https://github.com/alphagov/govuk_app_config/pull/183))

# 2.8.2

* Allow apps to configure the host and protocol for Statsd ([#180](https://github.com/alphagov/govuk_app_config/pull/180))

# 2.8.1

* Add `GdsApi::ContentStore::ItemNotFound` to `data_sync_excluded_exceptions` (https://github.com/alphagov/govuk_app_config/pull/178)
* Dependabot bumps to allow latest versions of logstasher ([#177](https://github.com/alphagov/govuk_app_config/pull/177)) and unicorn ([#175](https://github.com/alphagov/govuk_app_config/pull/175))

# 2.8.0

* Adds govuk_app_config version to every Sentry call (https://github.com/alphagov/govuk_app_config/pull/174)

# 2.7.1

* Fix broken data sync error handling for non-Rails apps (https://github.com/alphagov/govuk_app_config/pull/172)

# 2.7.0

* Ignore intermittent template retrieval errors from Slimmer (https://github.com/alphagov/govuk_app_config/pull/170)

# 2.6.0

* Ignore errors that occur in temporary environments (adds `active_sentry_environments` config) (https://github.com/alphagov/govuk_app_config/pull/168)

# 2.5.2

* Fix govuk_app_config in Ruby 2.7 environments by explicitly requiring the 'delegate' library (https://github.com/alphagov/govuk_app_config/pull/167)

# 2.5.1

* Increase scope of `data_sync_excluded_exceptions` so that it includes subclasses (https://github.com/alphagov/govuk_app_config/pull/165)

# 2.5.0

* Use delegator pattern for `GovukError.configure`, to allow custom `should_capture` (https://github.com/alphagov/govuk_app_config/pull/160)

# 2.4.1

* Bump 'sentry-raven' to 3.1.1 to improve grouping of errors (https://github.com/alphagov/govuk_app_config/pull/162)

# 2.4.0

* Add new GovukHealthcheck::Mongoid and GovukHealthcheck::RailsCache health checks (https://github.com/alphagov/govuk_app_config/pull/161)

# 2.3.0

* Remove unused SidekiqQueueSizeCheck healthcheck base class (https://github.com/alphagov/govuk_app_config/pull/156)

# 2.2.2

* Add www.googletagmanager.com and www.gstatic.com to Content Security Policy (https://github.com/alphagov/govuk_app_config/pull/153)

# 2.2.1

* Fix linting issues (https://github.com/alphagov/govuk_app_config/pull/149)

# 2.2.0

* Monkey patch `ActionDispatch::DebugExceptions#log_error` so it logs errors on a single line (https://github.com/alphagov/govuk_app_config/pull/147)

# 2.1.2

* Add missing ActiveRecord rescue_responses (https://github.com/alphagov/govuk_app_config/pull/142)

# 2.1.1

* Revert using sentry option of rails_report_rescued_exceptions (https://github.com/alphagov/govuk_app_config/pull/140)

# 2.1.0

* Stop exceptions rescued by rails from appearing in Sentry (https://github.com/alphagov/govuk_app_config/pull/138)

# 2.0.3

* Add hmrc-uk.digital.nuance.com (Nuance/HMRC Webchat provider) and gov.klick2contact.com (HMPO web chat provider) to connect-src CSP list (https://github.com/alphagov/govuk_app_config/pull/133)

# 2.0.2

* Add www.gov.uk to CSP list (https://github.com/alphagov/govuk_app_config/pull/129)
* Add hmrc-uk.digital.nuance.com (Nuance/HMRC Webchat provider) to script-src CSP list (https://github.com/alphagov/govuk_app_config/pull/130)


# 2.0.1

* Reorder requires to resolve: "NameError: uninitialized constant
  GovukAppConfig::Railtie::GovukLogging"

# 2.0.0

* Remove support for AWS X-Ray.

# 1.20.2

* Fix GdsApi::HTTPIntermittentServer errors no longer being filtered from
  exceptions sent to Sentry.

# 1.20.1

* Fix regression in error reporting code which caused an error.

# 1.20.0

* Fix CSP in development
* Add `youtube-nocookie.com` to consent security policy
* Update dependencies
* Update error reporting code

# 1.19.0

* Use `GOVUK_CSP_REPORT_ONLY` and `GOVUK_CSP_REPORT_URI` to configure
  content security policy.

# 1.18.1

* Fix incorrect report_uri= method usage in content security policy

# 1.18.0

* Use Rails DSL to configure content security policy, allowing apps to modify
  the policy and use nonce features.

# 1.17.0

* Tweak our CSP to work with 'dev.gov.uk'

# 1.16.3

* Revert PR #89 - it relies on an unreleased feature of aws-xray-sdk

# 1.16.2

* Don't log Context Missing Errors (`ERROR -- : can not find the current context.`)

# 1.16.1

* Return Critical status for SidekiqRedis if Redis raises a connection error.

# 1.16.0

* Add a DoubleClick domain to our content security policy.

# 1.15.1

* Fix the `UNICORN_TIMEOUT` setting, which previously resulted in a
  crash on start.

# 1.15.0

* Allow configuring the unicorn timeout through the `UNICORN_TIMEOUT`
  environment variable (default: 60).

# 1.14.0

* Add content security policy support.

# 1.13.1

* Remove formating from the Logstasher logger, used by default for the
  GDS API Adapters logging.

# 1.13.0

* Configure the GDS API Adapters logger to use logstasher
* More consistent log level configuration by default

# 1.12.0

* Make ActiveRecord healthcheck more accurate

# 1.11.3

* Add Initialized healthchecks

# 1.11.2

* Fix crash on start due to incorrect method invocation.

# 1.11.1

* Fix crash on start due to incorrect method invocation.

# 1.11.0

* Disable X-Ray entirely if the `GOVUK_APP_CONFIG_DISABLE_XRAY`
  environment variable is set.

# 1.10.0

* Only instrument the `aws_sdk` gem with AWS X-Ray if the
  `XRAY_PATCH_AWS_SDK` environment variable is present.

# 1.9.3

* Do not report Sidekiq queue thresholds in healthchecks which are
  infinite or NaN.

# 1.9.2

* Set a default segment name for XRay if the `GOVUK_APP_NAME`
  environment variable is missing, rather than throwing an exception.

# 1.9.1

* Make XRay log missing segments (such as when executing rake tasks)
  as an error, rather than throwing an exception.

# 1.9.0

* Record 1% of requests with AWS X-Ray.

# 1.8.0

* Handle a health check which raises an exception.
* Configure Sentry to only log on startup in the production Rails
  environment (if Rails is in use)

# 1.7.0

* Add various convenience health check classes which make it easier to add
  custom checks into apps without writing lots of code.

# 1.6.0

* Make health checks classes rather than instances, allowing internal data to
  be cached and improve performance.

# 1.5.1

* Set the `Content-Type` of healthchecks to `application/json`.
* Make the health check statuses symbols.

# 1.5.0

* Add healthcheck support.  See README.md for usage information.

# 1.4.2

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
* Don't send `ActionController::BadRequest` to Sentry

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
