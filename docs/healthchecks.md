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

## Built-in Checks

### `SidekiqRedis`

This checks that the app has a connection to Redis via Sidekiq.

### `ActiveRecord`

This checks that the app has a connection to the database via ActiveRecord.

### `ThresholdCheck`

This class is the basis for a check which compares a value with a warning or a
critical threshold. To implement this kind of check in your application, you
can inherit from the class.

```ruby
class MyThresholdCheck < GovukHealthcheck::ThresholdCheck
  def name
    :my_threshold_check
  end

  def value
    # get the value to be checked
  end

  def total
    # (optional) get the total value to be included in the details as extra
    # information
  end

  def warning_threshold
    # if the value is above this threshold, its status is warning
  end

  def critical_threshold
    # if the value is above this threshold, its status is critical
  end
end
```
