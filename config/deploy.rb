# config valid only for current version of Capistrano
lock '3.4.0'

set :rbenv_type, :user
set :rbenv_ruby, '2.2.2'

set :application, 'order_manager'
set :repo_url, 'git@github.com:shopbeam/order-manager.git'

# Default branch is :master
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/order_manager
set :deploy_to, '/home/ubuntu/www/order_manager'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, false

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('.env', 'config/database.yml', 'config/secrets.yml', 'config/newrelic.yml', 'config/cipher_key.asc')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :puma_init_active_record, true
set :sidekiq_role, :worker
set :puma_monit_service_name, "puma_order_manager"

namespace :deploy do

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
