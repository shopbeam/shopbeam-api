##override sidekiq restart task to use monit
#Rake::Task['sidekiq:restart'].clear_actions
#namespace :sidekiq do
#  task :restart do
#    on roles(fetch(:sidekiq_role)) do
#      sudo "/usr/bin/monit restart sidekiq_order_manager_production0"
#    end
#  end
#end
#
##prevent double sidekiq start
#Rake::Task['sidekiq:start'].clear_actions
