# Changelog

* Add Unicorn (our web server) as a dependency. Make sure to drop `gem 'unicorn'` from your Gemfile after upgrading.
* Use version [2.7.0 of the Sentry client][sentry-270].
* Don't send `ActionController::BadRequest`  to Sentry

[sentry-270]: https://github.com/getsentry/raven-ruby/commit/ef623824cb0a8a2f60be5fb7e12f80454da54fd7

## 0.3.0

* Add `time` and `gauge` to `GovukStatsd`
* Add `GovukError.configure` as an alias to `Raven.configure`

## 0.2.0

* First actual release with support for Sentry

## 0.1.0

Empty gem.
