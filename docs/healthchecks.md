# Health Checks

## Including checks in your app

Set up a route in your rack-compatible Ruby application, and pick the built-in
or custom checks you wish to perform.

For Rails apps:

```ruby
get "/healthcheck/ready", to: GovukHealthcheck.rack_response(
  GovukHealthcheck::SidekiqRedis,
  GovukHealthcheck::ActiveRecord,
  CustomCheck,
)
```

It also accepts objects, so classes can be initialized:

```ruby
get "/healthcheck/ready", to: GovukHealthcheck.rack_response(
  InitializedCheck.new(:param),
)
```

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
    "This is an optional custom message that will show up in the alert in Icinga"
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

## Built-in Checks

A convention used when naming these classes is that it should end with `Check`
if it must be subclassed to work, but a concrete class which works on its own
doesn't need that suffix. You should aim to follow this convention in your own
apps, ideally putting custom health checks into a `Healthcheck` module.

### `RailsCache`

This checks that the Rails cache store, such as Memcached, is acessible by
writing and reading back a cache entry called "healthcheck-cache".

### `Mongoid`

This checks that the app has a connection to its Mongo database via Mongoid.

### `SidekiqRedis`

This checks that the app has a connection to Redis via Sidekiq.

### `ActiveRecord`

This checks that the app has a connection to the database via ActiveRecord.
