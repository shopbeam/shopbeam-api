source 'https://rubygems.org'

gem 'rails', '4.2.3'

# Use postgresql as the database for Active Record
gem 'pg'

# State machine
gem 'aasm'

# Active Job adapter
gem 'sidekiq'

# Publish-Subscribe capabilities
gem 'wisper', '2.0.0.rc1'

# Browser API
gem 'watir-webdriver'

# Headless display
gem 'headless'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem 'rspec-rails', '~> 3.0'
end

group :test do
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'shoulda-matchers'
  gem 'cucumber'
  gem 'cucumber-rails', :require => false
  gem 'database_cleaner'
  gem 'rspec-expectations'
end
