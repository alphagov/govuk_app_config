require 'aws-xray-sdk/facets/rails/railtie'

Rails.application.config.xray = {
  name: ENV["GOVUK_APP_NAME"].to_s,
  patch: %I[net_http aws_sdk],
  sampling_rules: {
    default: {
      "fixed_target": 0,
      "rate": 0.01,
    },
  },
}
