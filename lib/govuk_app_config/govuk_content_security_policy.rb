module GovukContentSecurityPolicy
  # Generate a Content Security Policy (CSP) directive.
  #
  # Before making any changes please read our documentation: https://docs.publishing.service.gov.uk/manual/content-security-policy.html
  #
  # If you are making a change here you should consider 2 basic rules of thumb:
  #
  # 1. Are you creating a XSS risk? Adding unsafe-* declarations, allowing data: URLs or being overly permissive (e.g. https) risks these
  # 2. Is this change needed globally, if it's just one or two apps the change should be applied in them directly.

  GOVUK_DOMAINS = [
    "*.publishing.service.gov.uk",
    "*.#{ENV['GOVUK_APP_DOMAIN_EXTERNAL'] || ENV['GOVUK_APP_DOMAIN'] || 'dev.gov.uk'}",
    "www.gov.uk",
    "*.dev.gov.uk",
  ].uniq.freeze

  GOOGLE_ANALYTICS_DOMAINS = %w[www.google-analytics.com
                                ssl.google-analytics.com
                                stats.g.doubleclick.net
                                www.googletagmanager.com
                                www.region1.google-analytics.com
                                region1.google-analytics.com].freeze

  GOOGLE_STATIC_DOMAINS = %w[www.gstatic.com].freeze

  def self.build_policy(policy)
    # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/default-src
    policy.default_src :self

    # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/img-src
    # Note: we purposely don't include `data:` here because it produces a security risk.
    policy.img_src :self,
                   *GOVUK_DOMAINS,
                   *GOOGLE_ANALYTICS_DOMAINS, # Tracking pixels
                   # Speedcurve real user monitoring (RUM) - as per: https://support.speedcurve.com/docs/add-rum-to-your-csp
                   "lux.speedcurve.com",
                   # Some content still links to an old domain we used to use
                   "assets.digital.cabinet-office.gov.uk",
                   # Allow YouTube thumbnails
                   "https://img.youtube.com"

    # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/script-src
    # Note: we purposely don't include `data:`, `unsafe-inline` or `unsafe-eval` because
    # they are security risks, if you need them for a legacy app please only apply them at
    # an app level.
    policy.script_src :self,
                      *GOOGLE_ANALYTICS_DOMAINS,
                      *GOOGLE_STATIC_DOMAINS,
                      # Allow YouTube Embeds (Govspeak turns YouTube links into embeds)
                      "*.ytimg.com",
                      "www.youtube.com",
                      "www.youtube-nocookie.com"

    # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/style-src
    # Note: we purposely don't include `data:` or `unsafe-eval` because
    # they are security risks, if you need them for a legacy app please only apply them at
    # an app level.
    policy.style_src :self,
                     *GOOGLE_STATIC_DOMAINS,
                     # This allows `style=""` attributes and `<style>` elements.
                     # As of January 2023 our intentions to remove this were scuppered
                     # by Govspeak [1] using inline styles on tables. Until that
                     # is resolved we'll keep unsafe_inline
                     # [1]: https://github.com/alphagov/govspeak/blob/5642fcc4231f215d1c58ad7feb30ca42fb8cfb91/lib/govspeak/html_sanitizer.rb#L72-L73
                     :unsafe_inline

    # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/font-src
    # Note: we purposely don't include data here because it produces a security risk.
    policy.font_src :self

    # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/connect-src
    policy.connect_src :self,
                       *GOVUK_DOMAINS,
                       *GOOGLE_ANALYTICS_DOMAINS,
                       # Speedcurve real user monitoring (RUM) - as per: https://support.speedcurve.com/docs/add-rum-to-your-csp
                       "lux.speedcurve.com"

    # Disallow all <object>, <embed>, and <applet> elements
    #
    # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/object-src
    policy.object_src :none

    # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/frame-src
    policy.frame_src :self, *GOVUK_DOMAINS, "www.youtube.com", "www.youtube-nocookie.com" # Allow youtube embeds

    policy.report_uri ENV["GOVUK_CSP_REPORT_URI"] if ENV.include?("GOVUK_CSP_REPORT_URI")
  end

  def self.configure
    Rails.application.config.content_security_policy_report_only = ENV.include?("GOVUK_CSP_REPORT_ONLY")

    # Sets a nonce per request that can be set on script-src and style-src
    # directives depending on the value of Rails.application.config.content_security_policy_nonce_directives
    #
    # Note: if an application needs to set unsafe-inline they will need to
    # unset this generator (by setting this config option to nil in their application)
    Rails.application.config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }

    # This only applies the nonce generator to the script-src directive. We need this to
    # use unsafe-inline for style-src as a nonce will override it.
    #
    # When we want to apply it to style-src we can remove this line as the Rails default
    # is for both script-src and style-src
    Rails.application.config.content_security_policy_nonce_directives = %w[script-src]

    policy = Rails.application.config.content_security_policy(&method(:build_policy))

    # # allow apps to customise the CSP by passing a block e.g:
    # GovukContentSecuirtyPolicy.configure do |policy|
    #   policy.image_src(*policy.image_src, "https://i.ytimg.com")
    # end
    yield(policy) if block_given?

    policy
  end
end
