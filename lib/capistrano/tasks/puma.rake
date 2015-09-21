#override puma restart task to use monit
Rake::Task['puma:restart'].clear_actions
namespace :puma do
  task :restart do
    invoke 'puma:monit:restart'
  end
end
