require 'aws-xray-sdk/facets/rack'
require 'aws-xray-sdk/facets/rails/ex_middleware'

module GovukXRay
  def self.initialize(app)
    app.middleware.insert 0, XRay::Rack::Middleware
    app.middleware.use XRay::Rails::ExceptionMiddleware
  end

  def self.start
    # if aws-sdk is loaded, we want to instrument that too
    patch = Gem.loaded_specs.has_key?('aws-sdk-core') ?
              %I[aws_sdk net_http] : %I[net_http]

    # if there isn't a name set, attempting to record a segment will
    # throw an error
    govuk_app_name = ENV['GOVUK_APP_NAME']
    name = govuk_app_name.blank? ? 'xray' : govuk_app_name

    XRay.recorder.configure(
      name: name,
      patch: patch,
      context_missing: 'LOG_ERROR',
      sampling_rules: {
        version: 1,
        default: {
          'fixed_target': ENV.fetch('XRAY_SAMPLE_TARGET', 0).to_i,
          'rate': ENV.fetch('XRAY_SAMPLE_RATE', 0.01).to_f,
        },
        rules: [],
      },
    )
  end
end
