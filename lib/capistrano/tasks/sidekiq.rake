#override sidekiq restart task to use monit
Rake::Task['sidekiq:restart'].clear_actions
namespace :sidekiq do
  task :restart do
    invoke 'sidekiq:monit:restart'
  end
end
