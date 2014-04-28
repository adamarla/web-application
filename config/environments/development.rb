Webapp::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  #config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = true

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  config.action_mailer.default_url_options = {:host => "localhost:3000"}

  #Railscast #282 
  # Do not compress assets 
  config.assets.compress = false 
  # Expands the lines which load the assets 
  config.assets.debug = true 

  # Issue : AJAX requests were being issued twice in development mode. Why?  
  # Coz everything was being included twice - once from app/assets and again from 
  # public/assets 
  # 
  # Ref : http://stackoverflow.com/questions/7721502/rails-3-1-remote-requests-submitting-twice
  config.serve_static_assets = false

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

