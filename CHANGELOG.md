# 9.17.6

* Update dependencies

# 9.17.5

* Update dependencies

# 9.17.4

* Update CI workflow to handle concurrent releases ([#461](https://github.com/alphagov/govuk_app_config/pull/461))

# 9.17.3

* Update dependencies

# 9.17.2

* Update dependencies

# 9.17.1

* Update dependencies

# 9.17.0

* Add support for internationalisation of Rails framework strings ([#444](https://github.com/alphagov/govuk_app_config/pull/444))

# 9.16.11

* Update dependencies

# 9.16.10

* Update dependencies

# 9.16.9

* Update dependencies

# 9.16.8

* Update dependencies

# 9.16.7

* Update dependencies

# 9.16.6

* Update dependencies

# 9.16.5

* Update dependencies

# 9.16.4

* Update Github Workflows Checks (forcing version bump)

# 9.16.3

* Update dependencies

# 9.16.2

* Update dependencies

# 9.16.1

* Update dependencies

# 9.16.0

* GovukPrometheus - custom labels from rack env ([#424](https://github.com/alphagov/govuk_app_config/pull/424))

# 9.15.8

* Update dependencies

# 9.15.7

* Update dependencies

# 9.15.6

* Update dependencies

# 9.15.5

* Update dependencies

# 9.15.4

* Update dependencies

# 9.15.3

* Update dependencies

# 9.15.2

* Update dependencies

# 9.15.1

* Update dependencies

# 9.15.0

* Add Sanitiser::Strategy::SanitisingError to excluded exceptions list ([#402](https://github.com/alphagov/govuk_app_config/pull/402))

# 9.14.6

* Update dependencies

# 9.14.5

* Update dependencies

# 9.14.4

* Update dependencies

# 9.14.3

* Update SidekiqRedis healthcheck to work with Sidekiq 7 [#399](https://github.com/alphagov/govuk_app_config/pull/399)

# 9.14.2

* Update dependencies

# 9.14.1

* Update dependencies

# 9.14.0

* Configure `time_zone` with `govuk_time_zone` [#392](https://github.com/alphagov/govuk_app_config/pull/392)

# 9.13.1

* Update dependencies

# 9.13.0

* Add Slimmer::SourceWrapperNotFoundError to excluded exceptions.

# 9.12.0

* Set time_zone to London in all GOV.UK apps ([#381](https://github.com/alphagov/govuk_app_config/pull/381))

# 9.11.2

* Fix Logstasher monkey patch overriding patch from this library for OpenTelemetry errors ([#377](https://github.com/alphagov/govuk_app_config/pull/377))

# 9.11.1

* Fix OpenTelemetry errors when using with Logstasher gem ([#372](https://github.com/alphagov/govuk_app_config/pull/372))

# 9.11.0

* Add GDS::SSO::PermissionDeniedError to excluded exceptions list ([#366](https://github.com/alphagov/govuk_app_config/pull/366))

# 9.10.0

* Simplify the logic for deciding whether to initialize `GovukPrometheusExporter`. `GovukPrometheusExporter` provides the `/metrics` webserver and "exporter" process for aggregating counters in multi-process apps. govuk_app_config will now always attempt to initialize GovukPrometheusExporter except when running under `rails console`. The `GOVUK_PROMETHEUS_EXPORTER` environment variable no longer has any effect.

# 9.9.2

* Add single cookie consent api URLs ([#355](https://github.com/alphagov/govuk_app_config/pull/355))

# 9.9.1

* Stop sending SignalExceptions to Sentry by default.

# 9.9.0

* Drop support for Ruby 3.0. The minimum required Ruby version is now 3.1.4.

# 9.8.2

* Fix Ruby 3.3 compatibility ([#343](https://github.com/alphagov/govuk_app_config/pull/343))

# 9.8.1

* Revert "Add GOVUK domains to script src CSP" ([#336](https://github.com/alphagov/govuk_app_config/pull/336))

# 9.8.0

* Add GOVUK domains to script src CSP ([#334](https://github.com/alphagov/govuk_app_config/pull/334))

# 9.7.0

* Enable adding custom LogStasher fields from apps ([#327](https://github.com/alphagov/govuk_app_config/pull/327))

# 9.6.0

* Allow YouTube thumbnails from https://i.ytimg.com in the global Content Security Policy ([#328](https://github.com/alphagov/govuk_app_config/pull/328))

# 9.5.0

* Allow gov.uk domains to embed pages in the global Content Security Policy ([#325](https://github.com/alphagov/govuk_app_config/pull/325))

# 9.4.0

* Disallow any domain from embeding a page to prevent clickjacking ([#322](https://github.com/alphagov/govuk_app_config/pull/322))
* Fix GovukContentSecurityPolicy test ([#324](https://github.com/alphagov/govuk_app_config/pull/324))

# 9.3.0

* Get prometheus labels from controller, not params ([#320](https://github.com/alphagov/govuk_app_config/pull/320))

# 9.2.0

* Default to Prometheus histograms, not summaries ([#318](https://github.com/alphagov/govuk_app_config/pull/318))

# 9.1.0

* GovukAppConfig silences OpenTelemetry log output when running a rake task ([#311](https://github.com/alphagov/govuk_app_config/pull/311))
* Update warning message for Prometheus metric server address already in use.
* Add ability to support custom collectors in the Prometheus exporter.

# 9.0.4

* Fix an issue with Rails.logger being not an instance of ActiveSupport::Logger. Rails expects Rails.logger to have methods that Ruby STD Logger does not provide. e.g. `silence()` ([#309](https://github.com/alphagov/govuk_app_config/pull/309))

# 9.0.3

* When error is reported by Rails logger, the field is now logged as "error_message" in order to avoid overwriting the "message" field.

# 9.0.2

* GovukAppConfig no longer automatically initialises OpenTelemetry when running in `rails console`.

# 9.0.1

* Rename the "error" field in Rails logs from logstasher to "message" as error is supposed to be an object.

# 9.0.0

* BREAKING: JSON logs are no longer configured automatically for production Rails apps and are turned on with the GOVUK_RAILS_JSON_LOGGING environment variable ([#302](https://github.com/alphagov/govuk_app_config/pull/302))
* Add govuk_request_id to JSON logging for apps with gds-api-adapters ([#300](https://github.com/alphagov/govuk_app_config/pull/300))
* BREAKING: Remove $stdout, $stderr and $real_stdout redirections ([#300](https://github.com/alphagov/govuk_app_config/pull/300))
* BREAKING: Change error log behaviour from logging JSON to full string ([#300](https://github.com/alphagov/govuk_app_config/pull/300))
* Remove monkeypatch for errors ([#300](https://github.com/alphagov/govuk_app_config/pull/300))

# 8.1.1

* Fix prometheus_exporter to method patching compatible with OpenTelemetry.

# 8.1.0

* Add ability to enable OpenTelemetry instrumentation for Rails applications.

# 8.0.2

* Fix the ability to collect Sidekiq metrics in GovukPrometheusExporter. ([#299](https://github.com/alphagov/govuk_app_config/pull/299))

# 8.0.1

* Change the "source" field in Rails logs from logstasher from string representing IP host address to an empty object.

# 8.0.0

* BREAKING: Content Security Policy forbids the use of inline style attributes.

# 7.2.1

* Allow prometheus binding to fail with a warning rather than a crash ([#294](https://github.com/alphagov/govuk_app_config/pull/294))

# 7.2.0

* Suppress noisy Puma::HttpParserError errors ([#292](https://github.com/alphagov/govuk_app_config/pull/292))

# 7.1.0

* `GovukError` now allows specifying any name for the Sentry environment tag via the `SENTRY_CURRENT_ENV` environment variable. The environment name no longer has to match one of a fixed set of strings in order for `GovukError` to log events to Sentry.

# 7.0.0

* BREAKING: Remove [unicorn](https://rubygems.org/gems/unicorn/) and `GovukUnicorn`. All production GOV.UK apps are now using [Puma](https://rubygems.org/gems/puma/) instead.
* `GovukStatsd` is deprecated and will be removed in a future major release.

# 6.0.1

* Add support for configuring timeouts for puma-based applications

# 6.0.0

* BREAKING: Drop support for Ruby 2.7
* Register the Prometheus exporter in Sinatra middleware

# 5.1.0

* Add support to force-load the GovukPrometheusExporter by setting `GOVUK_PROMETHEUS_EXPORTER` to `force`. ([#282](https://github.com/alphagov/govuk_app_config/pull/282))

# 5.0.0

* Forbid base elements in the Content Security Policy
* BREAKING: Content Security Policy forbids unsafe-inline script-src and data: image-src. It provides a nonce generator. Apps that can't support this will need to amend their CSP configuration in an initializer, see [example](https://github.com/alphagov/signon/commit/ddcf31f5c30b8fd334e4aea74986b24bf2b0e9be) in signon. Any apps that still use jQuery 1.x will need unsafe-inline for Firefox compatibility.

# 4.13.0

* Flush log writes to stdout immediately so that structured (JSON) logs are not lost on crash or delayed indefinitely.

# 4.12.0

* Allow `https://img.youtube.com` as a CSP image source
* CSP only allows scripts, styles and fonts from self which reflects GOV.UK production behaviour
* Set the default CSP behaviour to be allow communication only to self
* Remove webchat scripts from the CSP, these are now handled in [government-frontend](https://github.com/alphagov/government-frontend/pull/2643)
* Remove `www.signin.service.gov.uk` from the CSP as it is no-longer used in GOV.UK
* Disallow data fonts in the global Content Security policy

# 4.11.1

* Remove govuk_i18n plural rules file

# 4.11.0

* Update Plek support to allow version 5
* Add I18n plural rules for Welsh (cy), Maltese (mt) and Chinese (zh) since Rails-I18n has [dropped support](https://github.com/svenfuchs/rails-i18n/pull/1017) for them in 7.0.6 ([#266](https://github.com/alphagov/govuk_app_config/pull/266))

# 4.10.1

* Fix an object ownership/sharing bug where the Rails log level was erroneously being set to `WARN` when initialising Sentry.

# 4.10.0

* Reduce log level for the Sentry gem from `INFO` to `WARN` to avoid polluting logs with uninformative messages. This only affects log messages from the Sentry gem itself, which go to `stdout`.

# 4.9.0

* Add GovukProxy::StaticProxy to forward Static asset requests by setting `GOVUK_PROXY_STATIC_ENABLED=true`.([#261](https://github.com/alphagov/govuk_app_config/pull/261))

# 4.8.0

* Enables Sentry environment names for EKS versions of integration, staging and production.([#260](https://github.com/alphagov/govuk_app_config/pull/260))

# 4.7.1

* Fix the ability to open the Rails console (`bundle exec rails c`) when running inside a container ([#257](https://github.com/alphagov/govuk_app_config/pull/257)).

# 4.7.0

* Adds Prometheus Sidekiq monitoring ([#255](https://github.com/alphagov/govuk_app_config/pull/255))

# 4.6.3

* Adds `region1.google-analytics.com` to the security policy for GA ([#250](https://github.com/alphagov/govuk_app_config/pull/250))

# 4.6.2

* Adds a new domain to the security policy for GA ([#248](https://https://github.com/alphagov/govuk_app_config/pull/248))

# 4.6.1

* Fixes warning message to refer to correct Sidekiq gem dependency name ([#243](https://github.com/alphagov/govuk_app_config/pull/243)).

# 4.6.0

* Add a warning for apps using GovukError with Sidekiq that don't have sentry-sidekiq installed ([#241](https://github.com/alphagov/govuk_app_config/pull/241)).
* Add internal Sidekiq exception "Sidekiq::JobRetry::Skip" to excluded exceptions ([#241](https://github.com/alphagov/govuk_app_config/pull/241)).

# 4.5.0

* Add lux.speedcurve.com to connect_src for GOV.UK Content Security Policy ([#232](https://github.com/alphagov/govuk_app_config/pull/232))
* Fix prometheus_exporter to only be enabled when the GOVUK_PROMETHEUS_EXPORTER env var is set to "true" ([#231](https://github.com/alphagov/govuk_app_config/pull/231)).
* Add Prometheus monitoring for EKS section to README.md ([#231](https://github.com/alphagov/govuk_app_config/pull/231)).
* Fix govuk_error being incompatible with Ruby >= 3 ([#233](https://github.com/alphagov/govuk_app_config/pull/233))
* Require Ruby 2.7 as the minimum supported Ruby version ([#233](https://github.com/alphagov/govuk_app_config/pull/233))
* Require Sentry 5 and Unicorn 6 major versions ([#237](https://github.com/alphagov/govuk_app_config/pull/237))
* Prevent sentry-rails logger warnings when govuk_error is used with non-Rails apps ([#234](https://github.com/alphagov/govuk_app_config/pull/234))

# 4.4.3

* Update prometheus exporter server to 0.0.0.0 from localhost  ([#227](https://github.com/alphagov/govuk_app_config/pull/227)).

# 4.4.2

* Update HMPO webchat address in security policy ([#225](https://github.com/alphagov/govuk_app_config/pull/225)).

# 4.4.1

* Fix issue where GovukPrometheusExporter module prevented the gem to load due to missing constant "PrometheusExporter" ([#224](https://github.com/alphagov/govuk_app_config/pull/224)).
* Lazy load the prometheus_exporter dependency for only apps that use GovukPrometheusExporter ([#224](https://github.com/alphagov/govuk_app_config/pull/224)).

# 4.4.0

* Add GovukPrometheusModule, to allow for export of prometheus metrics ([#223](https://github.com/alphagov/govuk_app_config/pull/223)).

# 4.3.0

* Remove Speedcurve's LUX from the connect-src policy ([#216](https://github.com/alphagov/govuk_app_config/pull/216)).

# 4.2.0

* Add pluralisation rules for Azerbaijani, Persian, Georgian, and Turkish. ([#219](https://github.com/alphagov/govuk_app_config/pull/219))

# 4.1.0

* Add Puma to dependencies ([#214](https://github.com/alphagov/govuk_app_config/pull/214)).

# 4.0.1

* Update Content Security Policy with new klick2contact.com subdomain ([#213](https://github.com/alphagov/govuk_app_config/pull/213)).

# 4.0.0

* BREAKING: replaces deprecated `sentry-raven` with `sentry-ruby` and `sentry-rails`. Follow the **[migration guide](https://docs.sentry.io/platforms/ruby/migration/)** before upgrading to this version of govuk_app_config to ensure full compatibility with the new gems.
* BREAKING: `GovukError.configure` can only be called once, and non-Rails apps will have to manually call `GovukError.configure` in order to initialise Sentry.
* BREAKING: apps will no longer increment the `error_reports_failed` statsd if events fail to get sent to Sentry.
* BREAKING: the behaviour of `before_send` has changed, and the `should_capture` method is deprecated.
* See pre-release notes below for details.
* PR: [#212](https://github.com/alphagov/govuk_app_config/pull/212)

# 4.0.0.pre.4

* Fix Sentry client initialisation ([#205](https://github.com/alphagov/govuk_app_config/pull/205)).
* BREAKING: non-Rails apps will need to manually call `GovukError.configure` in order to initialise Sentry.
* BREAKING: `GovukError.configure` can only be called once by the downstream application.

# 4.0.0.pre.3

* Include [sentry-rails](https://github.com/getsentry/sentry-ruby/tree/master/sentry-rails) by default ([#203](https://github.com/alphagov/govuk_app_config/pull/203)).

# 4.0.0.pre.2

* Fix default Sentry configuration ([#202](https://github.com/alphagov/govuk_app_config/pull/202)).
* BREAKING: this means no more `silence_ready` or `transport_failure_callback` options.

# 4.0.0.pre.1

* BREAKING: upgrades Sentry gem from `sentry-raven` to `sentry-ruby` ([#199](https://github.com/alphagov/govuk_app_config/pull/199)). There is a **[migration guide](https://docs.sentry.io/platforms/ruby/migration/)** you should follow before upgrading to this version of govuk_app_config.
* This release also fixes the `data_sync_excluded_exceptions` behaviour that was broken in v3.1.0 (later fixed in v3.3.0, which was released after 4.0.0.pre.1).
* Released as a pre-release to identify and fix any problems before a wider rollout.

# 3.3.0

* Revert the `should_capture`/`before_send` consolidation introduced in 3.1.0. This fixes the `data_sync_excluded_exceptions` behaviour that has been broken since v3.1.0. ([#211](https://github.com/alphagov/govuk_app_config/pull/211))

# 3.2.0

* Add Speedcurve's LUX to connect-src policy ([#206](https://github.com/alphagov/govuk_app_config/pull/206))

# 3.1.1

* Fix the new before_send behaviour & tests, and add documentation ([#197](https://github.com/alphagov/govuk_app_config/pull/197))

# 3.1.0

* Remove support for `should_capture` callbacks in favour of `before_send` ([#196](https://github.com/alphagov/govuk_app_config/pull/196))

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
