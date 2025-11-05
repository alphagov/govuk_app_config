require "prometheus_exporter/instrumentation"

module GovukPuma
  def self.configure_rails(config)
    config.port ENV.fetch("PORT", 3000)

    config.environment ENV.fetch("RAILS_ENV", "development")

    if ENV["GOVUK_APP_LOGROOT"]
      config.stdout_redirect "#{ENV['GOVUK_APP_LOGROOT']}/app.out.log" + "#{ENV['GOVUK_APP_LOGROOT']}/app.err.log"
    end

    # `worker_timeout` specifies how many seconds Puma will wait before terminating a worker.
    timeout = if ENV.fetch("RAILS_ENV", "development") == "development"
                3600
              else
                Integer(ENV.fetch("PUMA_TIMEOUT", 15))
              end
    config.worker_timeout timeout

    # When changing the min/max threads for Puma, also consider changing ActiveRecord to match.
    max_threads_count = ENV.fetch("RAILS_MAX_THREADS", 5)
    min_threads_count = ENV.fetch("RAILS_MIN_THREADS", max_threads_count)
    config.threads min_threads_count, max_threads_count

    # `workers` specifies the number of worker processes that Puma will fork.
    # The overall concurrency limit is worker count * max threads per worker.
    config.workers ENV.fetch("WEB_CONCURRENCY", 2)

    # `preload_app!` tells Puma to load application code before forking worker processes.
    # This reduces RAM wastage by making better use of copy-on-write.
    config.preload_app!

    config.before_fork do |_server|
      next unless ENV["GOVUK_APP_ROOT"]

      ENV["BUNDLE_GEMFILE"] = "#{ENV['GOVUK_APP_ROOT']}/Gemfile"
    end

    config.after_worker_boot do
      unless PrometheusExporter::Instrumentation::Puma.started?
        PrometheusExporter::Instrumentation::Puma.start
      end
      PrometheusExporter::Instrumentation::Process.start(type: "puma_worker")
    end

    # Allow puma to be restarted by `rails restart` command.
    config.plugin :tmp_restart
  end
end
