lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "govuk_app_config/version"

Gem::Specification.new do |spec|
  spec.name          = "govuk_app_config"
  spec.version       = GovukAppConfig::VERSION
  spec.authors       = ["GOV.UK Dev"]
  spec.email         = ["govuk-dev@digital.cabinet-office.gov.uk"]

  spec.summary       = "Base configuration for GOV.UK applications"
  spec.description   = "Base configuration for GOV.UK applications"
  spec.homepage      = "https://github.com/alphagov/govuk_app_config"
  spec.license       = "MIT"

  spec.required_ruby_version = ">= 3.1.4"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = %w[lib]

  spec.add_dependency "logstasher", "~> 2.1"
  spec.add_dependency "opentelemetry-exporter-otlp", ">= 0.25", "< 0.31"
  spec.add_dependency "opentelemetry-instrumentation-all", ">= 0.39.1", "< 0.75.0"
  spec.add_dependency "opentelemetry-sdk", "~> 1.2"
  spec.add_dependency "plek", ">= 4", "< 6"
  spec.add_dependency "prometheus_exporter", "~> 2.0"
  spec.add_dependency "puma", ">= 5.6", "< 7.0"
  spec.add_dependency "rack-proxy", "~> 0.7"
  spec.add_dependency "sentry-rails", "~> 5.3"
  spec.add_dependency "sentry-ruby", "~> 5.3"
  spec.add_dependency "statsd-ruby", "~> 1.5"

  spec.add_development_dependency "byebug"
  spec.add_development_dependency "climate_control"
  spec.add_development_dependency "rack-test", "~> 2.0"
  spec.add_development_dependency "rails", "~> 7"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.10"
  spec.add_development_dependency "rspec-its", "~> 2.0"
  spec.add_development_dependency "rubocop-govuk", "5.1.2"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "webmock"
end
