# Health Checks

## Check interface

A check is expected to be a class with the following methods:

```ruby
class CustomCheck
  def name
    :the_name_of_the_check
  end

  def status
    if critical_condition?
      :critical
    elsif warning_condition?
      :warning
    else
      :ok
    end
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

  # Optional
  def enabled?
    true # false if the check is not relevant at this time
  end
end
```

It is expected that these methods may cache their results for performance
reasons, if a user wants to ensure they have the latest value they should
create a new instance of the check first.

## Including checks in your app

Set up a route in your rack-compatible Ruby application, and pick the built-in
or custom checks you wish to perform.

For Rails apps:

```ruby
get "/healthcheck", to: GovukHealthcheck.rack_response(
  GovukHealthcheck::SidekiqRedis,
  GovukHealthcheck::ActiveRecord,
  CustomCheck,
)
```

## Built-in Checks

A convention used when naming these classes is that it should end with `Check`
if it must be subclassed to work, but a concrete class which works on its own
doesn't need that suffix. You should aim to follow this convention in your own
apps, ideally putting custom health checks into a `Healthcheck` module.

### `SidekiqRedis`

This checks that the app has a connection to Redis via Sidekiq.

### `ActiveRecord`

This checks that the app has a connection to the database via ActiveRecord.

### `ThresholdCheck`

This class is the basis for a check which compares a value with a warning or a
critical threshold.

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

### `SidekiqQueueLatencyCheck`

This class is the basis for a check which compares the Sidekiq queue latencies
with warning or critical thresholds.

```ruby
class MySidekiqQueueLatencyCheck < GovukHealthcheck::SidekiqQueueLatencyCheck
  def warning_threshold(queue:)
    # the warning threshold for a particular queue
  end

  def critical_threshold(queue:)
    # the critical threshold for a particular queue
  end
end
```

### `SidekiqQueueSizeCheck`

This class is the basis for a check which compares the Sidekiq queue sizes
with warning or critical thresholds.

```ruby
class MySidekiqQueueSizeCheck < GovukHealthcheck::SidekiqQueueSizeCheck
  def warning_threshold(queue:)
    # the warning threshold for a particular queue
  end

  def critical_threshold(queue:)
    # the critical threshold for a particular queue
  end
end
```


### `SidekiqRetrySizeCheck`

Similar to `SidekiqQueueSizeCheck`, this class is the basis for a check which
compares the Sidekiq retry set size with a warning and critical threshold.

```ruby
class MySidekiqRetrySizeCheck < GovukHealthcheck::SidekiqRetrySizeCheck
  def warning_threshold
    # the warning threshold for the retry set
  end

  def critical_threshold
    # the critical threshold for the retry set
  end
end
```
