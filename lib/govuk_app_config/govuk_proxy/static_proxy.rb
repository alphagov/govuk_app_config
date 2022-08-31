require "rack-proxy"

module GovukProxy
  class StaticProxy < Rack::Proxy
    def perform_request(env)
      request = Rack::Request.new(env)

      # use rack proxy to forward any requests for /assets/static/*
      # this regex needs to match the path set for `Rails.application.config.assets.prefix` in Static
      # https://github.com/alphagov/static/blob/main/config/initializers/assets.rb
      if request.path =~ %r{^/assets/static/}
        env["HTTP_HOST"] = @backend.host
        super(env)
      else
        @app.call(env)
      end
    end
  end
end
