source 'https://rubygems.org'

gem 'rails', '4.2.3'

# Use postgresql as the database for Active Record
gem 'pg'

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Use Puma as the app server
gem 'puma'

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'

# Action Mailer adapter
gem 'mailgun_rails'

# Background processing
gem 'sidekiq'

# Sidekiq Web UI
gem 'sinatra', require: nil

# State machine
gem 'aasm'

# Publish-Subscribe capabilities
gem 'wisper', '2.0.0.rc1'

# Browser API
gem 'watir-webdriver'

# Headless display
gem 'headless'

# Load environment variables
gem 'dotenv-rails'

# Pretty cron tasks
gem 'whenever'

# NewRelic monitoring
gem 'newrelic_rpm'

# Convenient diffing
gem 'diffy'

# Inline CSS for HTML mails
gem 'roadie-rails'

# Web parser
gem 'nokogiri'

# Money and currency conversion
gem 'money'
gem 'monetize'

# SFTP client
gem 'net-sftp'

# Heroku API client
gem 'heroku-api'

# Pretty printer for Ruby objects
gem 'awesome_print'

# API
gem 'grape'
gem 'grape-entity'

# Generate random tokens (TBA in Rails 5)
gem 'has_secure_token'

# Rack authentication
gem 'warden'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem 'rspec-rails', '~> 3.0'
end

group :development do
  gem 'mailcatcher'

  # Use Capistrano for deployment
  gem 'capistrano',         require: false
  gem 'capistrano-rbenv',   require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano3-puma',   require: false
  gem 'capistrano-sidekiq', require: false
  gem 'capistrano-rails',   require: false
end

group :test do
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'shoulda-matchers'
  gem 'cucumber'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'rspec-expectations'
  gem 'rspec-sidekiq'
  gem 'fakeredis', :require => 'fakeredis/rspec'
end
