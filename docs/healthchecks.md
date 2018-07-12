# Health Checks

Set up a route in your rack-compatible Ruby application, and pick the built-in
or custom checks you wish to perform.

Custom checks must be a class which implements
[this interface](../spec/lib/govuk_healthcheck/shared_interface.rb):

```ruby
class CustomCheck
  def name
    :custom_check
  end

  def status
    ThingChecker.everything_okay? ? OK : CRITICAL
  end

  # Optional
  def message
    "This is an optional custom message"
  end

  # Optional
  def details
    {
      extra: "This is an optional details hash",
    }
  end
end
```

For Rails apps:

```ruby
get "/healthcheck", to: GovukHealthcheck.rack_response(
  GovukHealthcheck::SidekiqRedis,
  GovukHealthcheck::ActiveRecord,
  CustomCheck,
)
```

This will check:
- Redis connectivity (via Sidekiq)
- Database connectivity (via ActiveRecord)
- Your custom healthcheck

Each check class gets instanced each time the health check end point is called.
This allows you to cache any complex queries speeding up performance.
