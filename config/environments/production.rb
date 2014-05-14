Webapp::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # For nginx:
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  config.cache_store = :dalli_store

  # Disable Rails's static asset server
  # In production, Apache or nginx will already do this
  config.serve_static_assets = false

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Configuring ActionMailer to work with Gmail's SMTP server
  #   Ref: http://guides.rubyonrails.org/action_mailer_basics.html
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: 'smtp.gmail.com',
    port: 587, 
    domain: 'gradians.com',
    user_name: 'mailer-noreply@gradians.com',
    password: 'shibb0leth',
    authentication: :plain, 
    enable_starttls_auto: true
  }

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Railscast #282 
  # Compress JavaScripts and CSS 
  config.assets.compress = true 
  config.assets.compile = false # change to true if not precompiling
  # Generate digests for assets URLs
  config.assets.digest = true 

  config.assets.precompile += ['admin.js', 'indie.js', 'uni.js', 'students.js', 'welcome.js', 'external.js', 'faq.js']
  config.assets.js_compressor = :uglifier

  # Railscasts #146
  config.after_initialize do
    ActiveMerchant::Billing::Base.mode = :test
    paypal_options = {
      :login => "akshay.damarla-facilitator_api1.gmail.com",
      :password => "1389079775",
      :signature => "AFcWxV21C7fd0v3bYYYRCpSSRl31Abi7nrcTSTJskutftvk4isuLv9dg"
    }
    ::STANDARD_GATEWAY = ActiveMerchant::Billing::PaypalGateway.new(paypal_options)
    ::EXPRESS_GATEWAY = ActiveMerchant::Billing::PaypalExpressGateway.new(paypal_options)
  end
end
