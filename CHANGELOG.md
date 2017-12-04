# Unreleased

- Support statsd methods of decrement, count, timing, set, and batch

# 1.0.0

* Add Unicorn (our web server) as a dependency
* Use version [2.7.0 of the Sentry client][sentry-270].
* Set up logging configuration for Rails applications.
* Don't send `ActionController::BadRequest`  to Sentry

[sentry-270]: https://github.com/getsentry/raven-ruby/commit/ef623824cb0a8a2f60be5fb7e12f80454da54fd7

### How to upgrade

* Remove `gem 'unicorn'` from your Gemfile
* Remove `gem 'logstasher'` from your Gemfile
* Remove all `config.logstasher.*` configs from `config/production.rb`

## 0.3.0

* Add `time` and `gauge` to `GovukStatsd`
* Add `GovukError.configure` as an alias to `Raven.configure`

## 0.2.0

* First actual release with support for Sentry

## 0.1.0

Empty gem.
