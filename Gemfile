source 'http://rubygems.org'

gem 'rails', '3.1.10'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'pg' # use PostgreSQL
gem 'haml-rails' # use haml as he default view generator

gem 'haml'
gem 'devise', "2.0.1"

group :development do
  gem 'annotate', '2.4.0' 
end 

gem 'cancan' # Ryan Bate's gem for defining roles and role permissions
gem 'formtastic'

# Gems used only for assets and not required in production 
# environment by default (Railscast #282)
group :assets do 
  gem 'sass-rails', "3.1.4"
  gem 'coffee-rails'
  gem 'uglifier'
end 

# Newer YAML parser. Default on Heroku Cedar is 'syck' which is unmaintained 
# $> rails console 
# $> YAML::ENGINE::yamler
# Ref : http://effectif.com/ruby-on-rails/syck-and-psych-yaml-parsers-on-heroku
# gem 'psych'

gem 'jquery-rails'
gem 'therubyracer'

gem 'rabl'
gem 'savon'
gem 'carrierwave' # for uploading 
gem 'spreadsheet'
gem 'simple_form'
gem 'country_select'
gem 'kaminari' # for pagination

gem 'delayed_job_active_record'

group :production do 
  gem 'thin'
end

gem 'dalli' # for caching

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
# gem 'ruby-debug'
# gem 'ruby-debug19', :require => 'ruby-debug'

# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
# group :development, :test do
#   gem 'webrat'
# end
