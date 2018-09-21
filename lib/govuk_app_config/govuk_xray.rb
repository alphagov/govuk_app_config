require 'aws-xray-sdk/facets/rack'
require 'aws-xray-sdk/facets/rails/ex_middleware'

module GovukXRay
  def self.initialize(app)
    app.middleware.insert 0, XRay::Rack::Middleware
    app.middleware.use XRay::Rails::ExceptionMiddleware
  end

  def self.start(app)
    XRay.recorder.configure(
      name: ENV['GOVUK_APP_NAME'].to_s,
      patch: %I[net_http aws_sdk],
      sampling_rules: {
        default: {
          'fixed_target': ENV.fetch('XRAY_SAMPLE_TARGET', 0).to_i,
          'rate': ENV.fetch('XRAY_SAMPLE_RATE', 0.01).to_f,
        },
      },
    )
  end
end
