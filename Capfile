# Load DSL and set up stages
require 'capistrano/setup'

# Include default deployment tasks
require 'capistrano/deploy'

# Include tasks from other gems included in your Gemfile
require 'capistrano/rbenv'
require 'capistrano/bundler'
require 'capistrano/puma'
require 'capistrano/puma/nginx'
require 'capistrano/puma/monit'
require 'capistrano/sidekiq'
require 'capistrano/sidekiq/monit'
require 'capistrano/rails/migrations'
require 'whenever/capistrano'

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
