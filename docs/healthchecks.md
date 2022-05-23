# Health Checks

GOV.UK apps often have special `/healthcheck` routes, which give an indication of whether the app is running and able to respond to requests. [Read about how health checks are used](https://docs.publishing.service.gov.uk/manual/alerts/app-healthcheck-not-ok.html).

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

Built-in checks you can use include:

- `GovukHealthcheck::RailsCache` - checks that the Rails cache store, such as Memcached, is acessible by writing and reading back a cache entry called "healthcheck-cache".

- `GovukHealthcheck::Mongoid` - checks that the app has a connection to its Mongo database via Mongoid.

- `GovukHealthcheck::SidekiqRedis` - checks that the app has a connection to Redis via Sidekiq.

- `GovukHealthcheck::ActiveRecord` - checks that the app has a connection to the database via ActiveRecord.

## Writing a custom healthcheck

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

Put custom health checks for your app into a `Healtcheck` module. Each custom check class should end with `Check`.
