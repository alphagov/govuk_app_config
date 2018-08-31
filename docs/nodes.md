# Nodes

The `GovukNodes` class is used to look up hostnames for servers based on their class.

This is a partial port of the script `govuk_node_list`.

## Use cases

In most circumstances applications shouldn't need to list servers dynamically,
however with the migration to AWS (with its transient servers) there are some
cases where it's necessary.

The specific case this was created for is so an app on a `backend` machine can
clear varnish caches for specific newly (re)published pages.  Because varnish
doesn't share its cache between the different `cache` machines, this app needs
to contact each `cache` machine directly.

## Usage

You can request an array of hostname strings by calling e.g.
```ruby
GovukNodes.of_class("cache")
```

This will return the correct list of hostnames for the environment the app is in,
regardless of whether it is hosted on AWS or Carrenza.

No further configuration is necessary.
