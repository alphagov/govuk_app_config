# Changelog

* Add Unicorn (our web server) as a dependency. Make sure to drop `gem 'unicorn'` from your Gemfile after upgrading.

## 0.3.0

* Add `time` and `gauge` to `GovukStatsd`
* Add `GovukError.configure` as an alias to `Raven.configure`

## 0.2.0

* First actual release with support for Sentry

## 0.1.0

Empty gem.
