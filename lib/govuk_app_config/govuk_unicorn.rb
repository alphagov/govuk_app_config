module GovukUnicorn
  def self.configure(config)
    config.worker_processes Integer(ENV.fetch("UNICORN_WORKER_PROCESSES", 2))

    config.timeout Integer(ENV.fetch("UNICORN_TIMEOUT", 60))

    if ENV["GOVUK_APP_LOGROOT"]
      config.stdout_path "#{ENV['GOVUK_APP_LOGROOT']}/app.out.log"
      config.stderr_path "#{ENV['GOVUK_APP_LOGROOT']}/app.err.log"
    end

    config.before_exec do |server|
      next unless ENV["GOVUK_APP_ROOT"]
      ENV["BUNDLE_GEMFILE"] = "#{ENV['GOVUK_APP_ROOT']}/Gemfile"
    end

    config.check_client_connection true
  end
end
