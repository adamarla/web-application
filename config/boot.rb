require 'rubygems'

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

# Force use of old YAML parser - syck - in all modes. Locally, in dev mode, 
# Ruby forces use of the new parser - psych. But in production, Heroku defaults 
# syck 
#require 'yaml'
#YAML::ENGINE::yamler = 'syck'
