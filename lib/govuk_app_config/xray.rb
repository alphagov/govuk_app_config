require 'aws-xray-sdk/facets/rails/railtie'

Rails.application.config.xray = {
  name: ENV["GOVUK_APP_NAME"].to_s,
  patch: %I[net_http aws_sdk],
  sampling_rules: {
    default: {
      "fixed_target": ENV.fetch("XRAY_SAMPLE_TARGET", 0).to_i,
      "rate": ENV.fetch("XRAY_SAMPLE_RATE", 0.01).to_f,
    },
  },
}
